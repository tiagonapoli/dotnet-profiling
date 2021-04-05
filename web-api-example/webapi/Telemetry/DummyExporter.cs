namespace webapi.Telemetry
{
    using System;
    using System.Diagnostics;
    using OpenTelemetry;

    public class DummyExporter : BaseExporter<Activity>
    {
        private static int count = 0;

        public override ExportResult Export(in Batch<Activity> batch)
        {
            foreach (var act in batch)
            {
                count++;
            }

            if (count % 1000 == 0)
            {
                Console.WriteLine($"Activities count {count}");
            }

            return ExportResult.Success;
        }
    }
}