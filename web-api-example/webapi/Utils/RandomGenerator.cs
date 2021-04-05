namespace webapi.Utils
{
    using System;

    public class RandomGenerator
    {
        private static readonly Random Global = new Random();
        
        [ThreadStatic]
        private static Random _local;

        public static double NextDouble()
        {
            var inst = _local;
            if (inst == null)
            {
                int seed;
                lock (Global) seed = Global.Next();
                _local = inst = new Random(seed);
            }

            return inst.NextDouble();
        }
    }
}