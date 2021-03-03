using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace PragueParking_3._0
{
    class Backend
    {
        private readonly string conn;
        public Backend(string conn)
        {
            this.conn = conn;
        }
        public bool IsRegOccupied(string regnum)
        {
            string regToCheck;
            string sqlQuery = "SELECT Regnum FROM ParkedVehicle "
                            + "WHERE Regnum = @Regnum;";
            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@Regnum", regnum);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();
                    regToCheck = reader[0].ToString();
                }
                catch
                {
                    return false;
                    throw new Exception();
                }
            }
            if (regToCheck.ToUpper().Trim() == regnum)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public bool AddVehicle(string regnum, int vehicleType)
        {
            string sqlQuery = "EXECUTE [AddVehicle] @Regnum = @regnum, @TypeID = @vehicleType;";
            int result = 0;

            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@regnum", regnum);
                command.Parameters.AddWithValue("@vehicleType", vehicleType);
                try
                {
                    connection.Open();
                    result = command.ExecuteNonQuery();
                }
                catch
                {
                    return false;
                    throw new Exception();
                }
            }
            return result > 0;
        }
        public bool RemoveVehicle(Vehicle regnum)
        {
            string sqlQuery = "EXECUTE [RemoveVehicle] @Regnum = @regnum";

            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@regnum", regnum.Regnum);
                try
                {
                    connection.Open();
                    command.ExecuteNonQuery();
                }
                catch 
                {
                    return false;
                    throw new Exception();
                }
                return true;
            }
        }
        public bool RemoveVehicleNoCost(Vehicle regnum)
        {
            string sqlQuery = "EXECUTE [RemoveVehicleNoCost] @Regnum = @regnum";

            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@regnum", regnum.Regnum);
                try
                {
                    connection.Open();
                    command.ExecuteNonQuery();
                }
                catch
                {
                    return false;
                    throw new Exception();
                }
                return true;
            }
        }
        public bool MoveVehicle(string regnum, int parkingSpot)
        {
            string sqlQuery =
                "EXECUTE [MoveVehicle] " +
                "@Regnum = @regnum, @ParkingSpot = @parkingSpot";

            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@regnum", regnum);
                command.Parameters.AddWithValue("@parkingSpot", parkingSpot);

                try
                {
                    connection.Open();
                    command.ExecuteNonQuery();
                }
                catch 
                {
                    return false;
                    throw new Exception();
                }
                return true;
            }
        }
        public Vehicle GetData(string regnum)
        {
            Vehicle filledVehicle = new Vehicle(regnum);
            string sqlQuery =
                             "SELECT TOP 1 InTime, OutTime, Fee " +
                             "FROM VehicleHistory " +
                             "WHERE @Regnum = @regnum " +
                             "ORDER BY OutTime DESC";

            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@regnum", regnum);

                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();

                    filledVehicle.TimeOfArrival = DateTime.Parse(reader[0].ToString());
                    filledVehicle.TimeOfDeparture = DateTime.Parse(reader[1].ToString());
                    filledVehicle.Fee = decimal.Parse(reader[2].ToString());
                   
                }
                catch
                {
                    throw new Exception();
                }
                return filledVehicle;
            }
        }
        public int GetSpot(string regnum)
        {
            int spotNumber = 0;
            string sqlQuery = "SELECT ps.SpotNumber FROM ParkingSpot ps "
                            + "JOIN ParkedVehicle pv ON ps.SpotID=pv.SpotID "
                            + "WHERE pv.Regnum = @Regnumber;";

            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);

                command.Parameters.AddWithValue("@Regnumber", regnum);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();
                    spotNumber = (int)reader[0];
                }
                catch
                {
                    spotNumber = -1;
                    throw new Exception();
                }
            }
            return spotNumber;
        }
        public List<Vehicle> DisplayAllSpots()
        {
            List<Vehicle> returnVehicles = new List<Vehicle>();
            string sqlQuery =
                "SELECT ps.SpotNumber, ISNULL(pv.Regnum, 'EMPTY') AS Regnum, ISNULL(pv.TypeID, '') AS TypeID " +
                "FROM ParkingSpot ps " +
                "FULL OUTER JOIN ParkedVehicle pv " +
                "ON ps.SpotID = pv.SpotID";

            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        int? spotNumber = int.Parse(reader[0].ToString());
                        string regnum = reader[1].ToString();
                        int? vehicleType = int.Parse(reader[2].ToString());

                        Vehicle vehicleList = new Vehicle(regnum, null, null, null, vehicleType, spotNumber);
                        returnVehicles.Add(vehicleList);
                    }
                }
                catch
                {
                    throw new Exception();
                }
                return returnVehicles;
            }
        }
        public Vehicle GetFeeForVehicle(string regnum)
        {
            Vehicle vehicle = new Vehicle(regnum);

            string sqlQuery = "GetFee";
            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.CommandType = CommandType.StoredProcedure;

                SqlParameter toPay = command.Parameters.Add("@FeeToPay", SqlDbType.Money);
                toPay.Direction = ParameterDirection.Output;

                command.Parameters.AddWithValue("@Regnum", regnum);

                try
                {
                    connection.Open();
                    command.ExecuteReader();
                    vehicle.Fee = (decimal)toPay.Value;
                }
                catch
                {
                    throw new Exception();
                }
            }
            sqlQuery = "SELECT InTime, GETDATE() FROM ParkedVehicle "
                     + "WHERE Regnum = @Regnum;";
            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@Regnum", regnum);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        vehicle.TimeOfArrival = DateTime.Parse(reader[0].ToString());
                        vehicle.TimeOfDeparture = DateTime.Parse(reader[1].ToString());
                    }
                }
                catch
                {
                    throw new Exception();
                }
            }
            return vehicle;
        }
        public List<Vehicle> OptimizeMC()
        {
            List<Vehicle> mcToReturn = new List<Vehicle>();
            string sqlQuery = 
                "SELECT SpotNumber, Regnum " +
                "FROM [OptimizeMC] " +
                "ORDER BY SpotNumber; ";

            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        Vehicle motorcycle = new Vehicle(reader[1].ToString());
                        motorcycle.SpotNumber = int.Parse(reader[0].ToString());
                        mcToReturn.Add(motorcycle);
                    }
                }
                catch
                {
                    throw new Exception();
                }
            }
            return mcToReturn;
        }
        public List<Vehicle> DisplayTwoDayParking(int amountOfHours)
        {
            List<Vehicle> returnVehicles = new List<Vehicle>();
            string sqlQuery = "SELECT SpotNumber, Regnum, TypeID, [Hours parked] FROM [VehiclesParked] "
                            + "WHERE [Hours Parked] >= @AmountOfHours "
                            + "ORDER BY [Hours Parked] DESC;";
            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@AmountOfHours", amountOfHours);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        Vehicle parkedVehicles = new Vehicle(reader[1].ToString());
                        parkedVehicles.SpotNumber = int.Parse(reader[0].ToString());
                        parkedVehicles.VehicleType = int.Parse(reader[2].ToString());
                        parkedVehicles.HoursParked = int.Parse(reader[3].ToString());
                        returnVehicles.Add(parkedVehicles);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            return returnVehicles;
        }
        public List<string[]> IncomeDay(string startDate, string endDate)
        {
            List<string[]> toReturn = new List<string[]>();
            string sqlQuery = "SELECT [Date], [Income] FROM [Income per day] "
                            + "WHERE [Date] BETWEEN @startDate AND @endDate";
            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@startDate", startDate);
                command.Parameters.AddWithValue("@endDate", endDate);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        string[] toAdd = { reader[0].ToString().Substring(0,10), reader[1].ToString().Substring(0,reader[1].ToString().Length - 2) };
                        toReturn.Add(toAdd);
                    }
                }
                catch
                {
                    throw new Exception();
                }
            }
            return toReturn;
        }
        public decimal IncomeInterval(string startingDate, string endingDate)
        {
            decimal valueToReturn = 0;
            string sqlQuery = "Income interval";
            using (SqlConnection connection = new SqlConnection(conn))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.CommandType = CommandType.StoredProcedure;
                SqlParameter returnValue = command.Parameters.Add("@AverageIncome", System.Data.SqlDbType.Money);
                returnValue.Direction = ParameterDirection.Output;
                command.Parameters.AddWithValue("@StartDate", startingDate);
                command.Parameters.AddWithValue("@EndDate", endingDate);
                try
                {
                    connection.Open();
                    command.ExecuteReader();
                    valueToReturn = (decimal)returnValue.Value;
                }
                catch
                {
                    throw new Exception();
                }
            }
            return valueToReturn;
        }
    }
}
