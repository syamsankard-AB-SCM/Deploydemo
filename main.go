package main

import (
	"fmt"
	"net"
	"time"

	"github.com/syamsankard-AB-SCM/tatacliq-backend/scm/golang/cliqutil"
	"github.com/syamsankard-AB-SCM/tatacliq-backend/scm/golang/core_msvc/command/cor_cmd_couchbase/internal/global"
	"github.com/syamsankard-AB-SCM/tatacliq-backend/scm/golang/core_msvc/command/cor_cmd_couchbase/internal/service"
	pb "github.com/syamsankard-AB-SCM/tatacliq-backend/scm/golang/core_msvc/command/cor_cmd_couchbase/pkg/generated"
	"github.com/syamsankard-AB-SCM/tatacliq-backend/scm/golang/core_msvc/common/couchbase"
	"go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"
	"go.opentelemetry.io/otel"
	"google.golang.org/grpc"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/reflection"
)

func main() {
	// Initiliazing global variables
	global.Viper = cliqutil.LoadConfig()
	global.Logger = *cliqutil.Init(global.Viper.GetString("logging.level"))

	// Initilizing Couchbase Client
	err := couchbase.NewCBConn(global.Viper.GetString("couchbase.host"),
		global.Viper.GetString("couchbase.username"), global.Viper.GetString("couchbase.password"))
	if err != nil {
		global.Logger.Panic(cliqutil.LogMessage{Function: "Main", Service: global.ServiceName, Msg: "Failed to initialize connection"})
	}

	lis, err := net.Listen("tcp", global.Viper.GetString("server.address"))
	if err != nil {
		global.Logger.Panic(cliqutil.LogMessage{Function: "Main", Service: global.ServiceName, Msg: err.Error()})
	}

	// Initilizing Tracer
	shutdown := cliqutil.InitOTel(global.Viper.GetString("otel-agent.address"), global.ServiceName)
	defer shutdown()
	_ = otel.GetTracerProvider().Tracer(global.ServiceName)

	opts := []grpc.ServerOption{
		grpc.UnaryInterceptor(otelgrpc.UnaryServerInterceptor()),
		grpc.KeepaliveParams(keepalive.ServerParameters{
			MaxConnectionAge: time.Minute * time.Duration(global.Viper.GetInt("server.maxConnectionAge")),
		}),
	}
	s := grpc.NewServer(opts...)
	pb.RegisterCouchbaseCommandServer(s, &service.CouchbaseCommandServer{})
	if !global.Viper.GetBool("server.production") {
		// Register reflection service on gRPC server.
		reflection.Register(s)
	}
	global.Logger.Info(cliqutil.LogMessage{
		Service: global.ServiceName, Msg: fmt.Sprintf("gRPC Service started at: %s", global.Viper.GetString("server.address"))})
	if err := s.Serve(lis); err != nil {
		global.Logger.Panic(cliqutil.LogMessage{Function: "Main", Service: global.ServiceName, Msg: err.Error()})
	}
}
