var builder = DistributedApplication.CreateBuilder(args);

var cache = builder.AddRedis("cache");
// var messaging = builder.AddRabbitMQ("messaging");

var apiService = builder.AddProject<Projects.HelloWorldAspire_ApiService>("apiservice");

builder.AddProject<Projects.HelloWorldAspire_Web>("webfrontend")
    .WithReference(cache)
    .WithReference(apiService);
    // .WithReference(messaging);

builder.Build().Run();
