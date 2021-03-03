using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PragueParking_3._0
{
    class Frontend
    {
        private Backend database;
        public Frontend(string conn)
        {
            database = new Backend(conn);
        }
        public void MainMenu()
        {
            while (true)
            {
                Console.Clear();
                Console.WriteLine("Prague Parking 3.0");
                Console.WriteLine("--------------------");
                Console.WriteLine("[1] - Add vehicle");
                Console.WriteLine("[2] - Remove vehicle");
                Console.WriteLine("[3] - Move vehicle");
                Console.WriteLine("[4] - Display parking lot");
                Console.WriteLine("[5] - Search for vehicle");
                Console.WriteLine("[6] - Optimize MC");
                Console.WriteLine("[7] - Display 48 hour parking");
                Console.WriteLine("[8] - Income for day");
                Console.WriteLine("[9] - Income for interval");
                Console.WriteLine("[10]- Remove vehicle (WITHOUT CHARGE)");
                Console.Write("Choice: ");
                bool input = int.TryParse(Console.ReadLine(), out int result);
                switch (result)
                {
                    case 1:
                        AddVehicle();
                        break;
                    case 2:
                        RemoveVehicle();
                        break;
                    case 3:
                        MoveVehicle();
                        break;
                    case 4:
                        DisplayParkingLot();
                        break;
                    case 5:
                        SearchForVehicle();
                        break;
                    case 6:
                        OptimizeMC();
                        break;
                    case 7:
                        DisplayTwoDayParking();
                        break;
                    case 8:
                        IncomeDay();
                        break;
                    case 9:
                        IncomeInterval();
                        break;
                    case 10:
                        RemoveVehicleNoCost();
                        break;
                    default:
                        break;
                }
            }
        }
        private void AddVehicle()
        {
            string regnum = "";
            try
            {
                Console.Clear();

                regnum = GetRegnum();

                while (database.IsRegOccupied(regnum))
                {
                    Console.Clear();

                    Console.WriteLine("The vehicle |{0}| is already parked here.", regnum);
                    Console.WriteLine("\nPress ENTER to try again.");
                    Console.ReadLine();
                    regnum = GetRegnum();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.ReadLine();
            }
           
            int vehicleType = GetVehicleType();

            bool succesful = database.AddVehicle(regnum, vehicleType);
            if (succesful)
            {
                Console.Clear();
                Console.WriteLine("Success! |{0}| parked at spot [{1}].", regnum, database.GetSpot(regnum));
                Console.WriteLine("\n\nPress ENTER to return to menu...");
            }
            else
            {
                Console.Clear();
                Console.WriteLine("Fail! Could not add |{0}| to lot. Try again...", regnum);
                Console.WriteLine("\n\nPress ENTER to return to menu...");
            }
            Console.ReadLine();
        }
        private void RemoveVehicle()
        {
            Console.Clear();

            string regnum = GetRegnum();
            while (!database.IsRegOccupied(regnum))
            {
                Console.Clear();
                Console.WriteLine("|{0}| not found!", regnum);
                Console.WriteLine("Press ENTER to try again");
                Console.ReadLine();
                regnum = GetRegnum();
            }

            Vehicle removeRegnum = new Vehicle(regnum);
            bool succesful = database.RemoveVehicle(removeRegnum);
            if (succesful)
            {
                Console.Clear();
                Vehicle removedVehicle = database.GetData(regnum);
                Console.WriteLine("The vehicle |{0}| was succesfully removed!", regnum);
                Console.WriteLine("Arrival: {0:g}\nDeparture: {1:g}\nFee: {2:0.00} Kr", removedVehicle.TimeOfArrival, removedVehicle.TimeOfDeparture, removedVehicle.Fee);
                Console.WriteLine("\n\nPress ENTER to return to menu...");
            }
            else
            {
                Console.WriteLine("|{0}| could not be removed!", regnum);
                Console.WriteLine("\n\nPress ENTER to return to menu...");
            }
            Console.ReadLine();
        }
        private void RemoveVehicleNoCost()
        {
            Console.Clear();

            string regnum = GetRegnum();
            while (!database.IsRegOccupied(regnum))
            {
                Console.Clear();
                Console.WriteLine("|{0}| not found!", regnum);
                Console.WriteLine("Press ENTER to try again");
                Console.ReadLine();
                regnum = GetRegnum();
            }

            Vehicle vehicle = new Vehicle(regnum);
            vehicle.Fee = 0;

            bool success = database.RemoveVehicleNoCost(vehicle);
            if (success)
            {
                Console.Clear();
                Vehicle removedVehicle = database.GetData(regnum);
                Console.WriteLine("The vehicle |{0}| was succesfully removed!", regnum);
                Console.WriteLine("Arrival: {0:g}\nDeparture: {1:g}\nFee: {2:0.00} Kr", removedVehicle.TimeOfArrival, removedVehicle.TimeOfDeparture, removedVehicle.Fee);
                Console.WriteLine("\n\nPress ENTER to return to menu...");
            }
            else
            {
                Console.WriteLine("|{0}| could not be removed!", regnum);
                Console.WriteLine("\n\nPress ENTER to return to menu...");
            }
            Console.ReadLine();
        }
        private void MoveVehicle()
        {
            Console.Clear();

            string regnum = GetRegnum();
            while (!database.IsRegOccupied(regnum))
            {
                Console.Clear();
                Console.WriteLine("|{0}| not found!", regnum);
                Console.WriteLine("Press ENTER to try again");
                Console.ReadLine();
                regnum = GetRegnum();
            }
            int parkingSpot = GetParkingSpot();

            bool successful = database.MoveVehicle(regnum, parkingSpot);
            if (successful)
            {
                Console.WriteLine("|{0}| moved to spot {1}", regnum, parkingSpot);
                Console.WriteLine("\n\nPress ENTER to return to menu...");
            }
            else
            {
                Console.WriteLine("|{0}| could not be parked on spot {1}", regnum, parkingSpot);
                Console.WriteLine("\n\nPress ENTER to return to menu...");
            }
            Console.ReadLine();

        }
        private int GetParkingSpot()
        {
            bool validInput = false;
            int output = 0;
            do
            {
                Console.Write("Enter spot to move [1-100]: ");
                string input = Console.ReadLine();
                bool checkInt = int.TryParse(input, out output);
                if (!checkInt)
                {
                    Console.WriteLine("Only numbers.");
                }
                else if (output < 1 || output > 100)
                {
                    Console.WriteLine("Can choose number between 1-100.");
                }
                else
                {
                    validInput = true;
                }
            } while (!validInput);
            return output;
        }
        private string GetRegnum()
        {
            bool validInput = false;
            string regnum;
            do
            {
                Console.Clear();

                Console.Write("Enter registration number: ");
                regnum = Console.ReadLine().ToUpper().Trim();

                if (regnum.Length < 3 || regnum.Length > 10)
                {
                    Console.WriteLine("Fail! Only between 3 - 10 characters.");
                    Console.WriteLine("\nPress ENTER to try again.");
                }
                else
                {
                    validInput = true;
                }
            } while (!validInput);

            return regnum;
        }
        private int GetVehicleType()
        {
            bool validInput = false;
            bool userInput;
            int vehicleType;
            do
            {
                Console.Clear();

                Console.WriteLine("[1] = MotorCycle\n[2] = CAR ");
                Console.Write("What type of vehicle is it: ");
                userInput = int.TryParse(Console.ReadLine(), out vehicleType);
                if (vehicleType == 1 || vehicleType == 2)
                {
                    validInput = true;
                }
                else
                {
                    Console.Clear();
                    Console.WriteLine("Invalid input! Only enter [1] - MC or [2] - CAR.");
                    Console.WriteLine("\nPress ENTER to try again.");
                    Console.ReadLine();
                }
            } while (!validInput);
            return vehicleType;
        }
        private void DisplayParkingLot()
        {
            Console.Clear();

            List<Vehicle> parkedVehicles = database.DisplayAllSpots();

            Console.ForegroundColor = ConsoleColor.DarkYellow;
            Console.WriteLine("Car - Yellow");
            Console.ForegroundColor = ConsoleColor.DarkCyan;
            Console.WriteLine("Motorcycle - Blue");
            Console.ResetColor();
            Console.WriteLine("__________________________________");
            for (int i = 0; i < parkedVehicles.Count; i++)
            {

                int spot = (int)parkedVehicles[i].SpotNumber;
                if (parkedVehicles[i].VehicleType == 1 && (i < parkedVehicles.Count - 1) && (parkedVehicles[i].SpotNumber == parkedVehicles[i + 1].SpotNumber))
                {
                    Console.Write("{0}: ", spot);
                    Console.ForegroundColor = ConsoleColor.DarkCyan;
                    Console.Write("|" + parkedVehicles[i].Regnum + "|");
                    Console.WriteLine("{0}| ", parkedVehicles[i + 1].Regnum);
                    Console.ResetColor();
                    i++;
                }
                else if (parkedVehicles[i].VehicleType == 0)
                {
                    Console.Write("{0}: ", spot);
                    Console.ForegroundColor = ConsoleColor.DarkGreen;
                    Console.WriteLine(parkedVehicles[i].Regnum);
                    Console.ResetColor();
                }
                else
                {
                    if (parkedVehicles[i].VehicleType == 1)
                    {
                        Console.Write("{0}: ", spot);
                        Console.ForegroundColor = ConsoleColor.DarkCyan;
                        Console.WriteLine("|" + parkedVehicles[i].Regnum + "|");
                        Console.ResetColor();
                    }
                    else
                    {
                        Console.Write("{0}: ", spot);
                        Console.ForegroundColor = ConsoleColor.DarkYellow;
                        Console.WriteLine("|" + parkedVehicles[i].Regnum + "|");
                        Console.ResetColor();
                    }
                }
            }
            Console.ReadLine();
        }
        private void SearchForVehicle()
        {
            Console.Clear();

            string regnum = GetRegnum();
            while (!database.IsRegOccupied(regnum))
            {
                Console.Clear();
                Console.WriteLine("|{0}| not found!", regnum);
                Console.WriteLine("Press ENTER to try again");
                Console.ReadLine();
                regnum = GetRegnum();
            }

            int spot = database.GetSpot(regnum);

            Vehicle vehicle = database.GetFeeForVehicle(regnum);
            TimeSpan timeSpan = (DateTime)vehicle.TimeOfDeparture - (DateTime)vehicle.TimeOfArrival;

            Console.Clear();
            Console.WriteLine("|{0}| parked on spot [{1}]", regnum, spot);
            Console.WriteLine("Time parked: {0:0} hours {1:0} minutes", timeSpan.Hours, timeSpan.Minutes);
            Console.WriteLine("Current cost: {0:0.00} kr and counting.", vehicle.Fee);
            Console.WriteLine("\n\nPress ENTER to return to menu...");
            Console.ReadLine();
        }
        private void OptimizeMC()
        {
            Console.Clear();
            List<Vehicle> singleMC = database.OptimizeMC();
            if (singleMC.Count < 2)
            {
                Console.WriteLine("Parking lot already optimized.");
            }
            else
            {
                while (singleMC.Count >= 2)
                {
                    int moveFrom = (int)singleMC[singleMC.Count - 1].SpotNumber;
                    int moveTo = (int)singleMC[0].SpotNumber;


                    string fromRegnum = singleMC[singleMC.Count - 1].Regnum;
                    string toRegnum = singleMC[0].Regnum;

                    bool succesful = database.MoveVehicle(fromRegnum, moveTo);
                    if (succesful)
                    {
                        Console.WriteLine("|{0}| moved from spot [{1}] => [{2}]", fromRegnum, moveFrom, moveTo);
                        Console.WriteLine("Where |{0}| is also parked", toRegnum);
                        Console.WriteLine("\n\nPress ENTER to return to menu...");
                        singleMC.RemoveAt(singleMC.Count - 1);
                        singleMC.RemoveAt(0);
                    }
                }
            }
            Console.ReadLine();
        }
        private void DisplayTwoDayParking()


        {
            Console.Clear();
            Console.WriteLine("|Vehicles currently parked over 48 hours|");
            Console.WriteLine("-------------------------------------------");
            List<Vehicle> parkedVehicles = database.DisplayTwoDayParking(48);
            foreach (Vehicle vehicle in parkedVehicles)
            {
                Console.WriteLine("Hours: {0}  |  Spot: {1}  |  Reg: {2}  |  Type: {3}", vehicle.HoursParked, vehicle.SpotNumber, vehicle.Regnum, vehicle.VehicleType == 1 ? "Motorcycle" : "Car");
            }
            Console.WriteLine("\n\nPress ENTER to return to menu...");
            Console.ReadLine();
        }
        private void IncomeDay()
        {
            Console.Clear();
            Console.WriteLine("|Income for given day|");
            string date = GetDate();
            List<string[]> income = database.IncomeDay(date, date);
            if (income.Count > 0)
            {
                Console.WriteLine("{0} - Income: {1} kr.", income[0][0], income[0][1]);
                Console.WriteLine("\n\nPress ENTER to return to menu...");
            }
            else
            {
                Console.WriteLine("On {0} - there was no income.", date);
                Console.WriteLine("\n\nPress ENTER to return to menu...");
            }
            Console.ReadLine();
        }
        private void IncomeInterval()
        {
            Console.Clear();
            Console.WriteLine("|Income for given interval|");
            string startDate = GetDate("start");
            string endDate = GetDate("end");
            List<string[]> income = database.IncomeDay(startDate, endDate);
            decimal averageIncome = database.IncomeInterval(startDate, endDate);
            foreach (string[] gi in income)
            {
                Console.WriteLine("{0} - Income: {1} kr.", gi[0], gi[1]);
            }
            Console.WriteLine("{0} - {1} - Average income for timespan: {2:0.00} kr", startDate, endDate, averageIncome);
            Console.WriteLine("\n\nPress ENTER to return to menu...");
            Console.ReadLine();
        }
        private string GetDate(string str = "")
        {
            bool validInput = false;
            string date;
            do
            {
                Console.Write("Enter the {0}date (YYYYMMDD): ", str);
                date = Console.ReadLine();
                if (!DateTime.TryParseExact(date, "yyyyMMdd", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime dt))
                {
                    Console.WriteLine("Invalid input! Use YYYYMMDD.");
                }
                else
                {
                    validInput = true;
                }
            } while (!validInput);

            return date;
        }
    }
}
