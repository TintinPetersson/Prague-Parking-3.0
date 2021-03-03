using System;

namespace PragueParking_3._0
{
    class Vehicle
    {
        private string regnum;
        private DateTime? timeOfArrival;
        private DateTime? timeOfDeparture;
        private decimal? fee;
        private int? vehicleType;
        private int? spotNumber;
        private int? hoursParked;

        public string Regnum { get => regnum; }
        public DateTime? TimeOfArrival { get => timeOfArrival; set => timeOfArrival = value; }
        public DateTime? TimeOfDeparture { get => timeOfDeparture; set => timeOfDeparture = value; }
        public decimal? Fee { get => fee; set => fee = value; }
        public int? VehicleType { get => vehicleType; set => vehicleType = value; }
        public int? SpotNumber { get => spotNumber; set => spotNumber = value; }
        public int? HoursParked { get => hoursParked; set => hoursParked = value; }

        public Vehicle(string regnum, DateTime? timeOfArrival = null, DateTime? timeOfDeparture = null,
                       decimal? fee = null, int? vehicleType = null, int? spotNumber = null)
        {
            this.regnum = regnum;
            this.timeOfArrival = timeOfArrival;
            this.timeOfDeparture = timeOfDeparture;
            this.fee = fee;
            this.vehicleType = vehicleType;
            this.spotNumber = spotNumber;
        }
    }
}
