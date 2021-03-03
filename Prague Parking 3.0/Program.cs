using System;
namespace PragueParking_3._0
{
    class Program
    {

          
        static void Main(string[] args)
        {
            string conn = @"Data Source=LAPTOP-2UTSSLFS\SQLEXPRESS;Initial Catalog=PragueParking3;Integrated Security=True";
            Frontend menu = new Frontend(conn);
            menu.MainMenu();

              
        }
    }
}
