using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace webapi.Controllers
{
    using System.Collections.Concurrent;
    using System.Diagnostics;
    using webapi.Utils;

    [ApiController]
    [Route("api")]
    public class WeatherForecastController : ControllerBase
    {
        private static ConcurrentDictionary<string, int> _concurrentDictionary = new();
        
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        private readonly ILogger<WeatherForecastController> _logger;

        public WeatherForecastController(ILogger<WeatherForecastController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IEnumerable<WeatherForecast> Get()
        {
            var rng = new Random();
            return Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = DateTime.Now.AddDays(index),
                TemperatureC = rng.Next(-20, 55),
                Summary = Summaries[rng.Next(Summaries.Length)]
            })
            .ToArray();
        }
        
        [HttpGet]
        [Route("exception/{amount}")]
        public string ThrowExceptions(int amount)
        {
            long count = 0;
            for (int i = 0; i < amount; i++)
            {
                try
                {
                    throw new Exception("teste");
                }
                catch (Exception ex)
                {
                    count += ex.Message.Length;
                }
            }

            return "ok";
        }
        
        [HttpGet]
        [Route("log")]
        public string Log()
        {
            Console.WriteLine($"sw[{RandomGenerator.NextDouble()}]]");
            return "ok";
        }
        
        [HttpGet]
        [Route("on-cpu")]
        public string OnCPU()
        {
            var sw = Stopwatch.StartNew();
            var iter = 0;
            while (sw.ElapsedMilliseconds < 100)
            {
                iter++;
                for (int i = 0; i < 300_000; i++)
                {
                    Math.Sqrt(i);
                }
            }
            sw.Stop();
            Console.WriteLine($"sw[{sw.ElapsedMilliseconds}] - iter[{iter}]");
            return "ok";
        }
        
        [HttpGet]
        [Route("off-cpu")]
        public string OffCPU()
        {
            Task.Delay(100).Wait();
            return "ok";
        }
        
        [HttpGet]
        [Route("concurrent-dict/{id}")]
        public string ConcurrentDict(string id)
        {
            _concurrentDictionary[id] = 1;
            for (int i = 0; i < 1000; i++)
            {
                _concurrentDictionary[id] += i;
            }
            
            return _concurrentDictionary[id].ToString();
        }
        
        [HttpGet]
        [Route("slow-firstordefault-linq")]
        public string SlowFindAllLinq()
        {
            var list = new List<double>();
            for (int i = 0; i < 100; i++)
            {
                var rnd = RandomGenerator.NextDouble();
                for (int j = 0; j < 100; j++)
                {
                    list.Add(rnd);    
                }
            }

            var val = Enumerable.FirstOrDefault(list, el => Math.Abs(el - 1.0) < 0.0001);
            return $"{val}";
        }
    }
}
