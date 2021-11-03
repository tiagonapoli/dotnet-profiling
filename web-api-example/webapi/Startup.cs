using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;

namespace webapi
{
    using OpenTelemetry;
    using OpenTelemetry.Exporter;
    using OpenTelemetry.Resources;
    using OpenTelemetry.Trace;
    using Prometheus;
    using Prometheus.DotNetRuntime;
    using webapi.Telemetry;

    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;

            DotNetRuntimeStatsBuilder.Customize()
                .WithExceptionStats(CaptureLevel.Errors)
                .StartCollecting();
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {

            services.AddControllers();
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "webapi", Version = "v1" });
            });
            
            services.AddOpenTelemetryTracing((builder) => builder
                .SetResourceBuilder(ResourceBuilder.CreateDefault().AddService("webapi"))
                .AddAspNetCoreInstrumentation()
                .AddHttpClientInstrumentation()
                .AddProcessor(new SimpleActivityExportProcessor(new DummyExporter()))
                .SetSampler(new TraceIdRatioBasedSampler(0.001)));
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseSwagger();
                app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "webapi v1"));
            }

            app.UseRouting();

            app.UseAuthorization();

            app.UseMetricServer();
            
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }
    }
}
