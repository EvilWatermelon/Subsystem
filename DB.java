package db2;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Main
{
	static
	{
		try
		{
			Class.forName("oracle.jdbc.driver.OracleDriver");
			Class.forName("com.mysql.jdbc.Driver");
		}
		catch(ClassNotFoundException e)
		{
			e.printStackTrace();
		}
	}
	
	public static void main(String[] args)
	{
		//"jdbc:mysql://sql11.freesqldatabase.com:3306/sql11175701?autoReconnect=true&useSSL=false","sql11175701","nHHfZkV96F"
		//"jdbc:oracle:thin:@studidb.gm.fh-koeln.de:1521:VLESUNG","user","pw"
		try(Connection connection = DriverManager.getConnection("jdbc:oracle:thin:@studidb.gm.fh-koeln.de:1521:VLESUNG","user","pw"))
		{
			//"SHOW TABLES FROM sql11175701"
			//"SELECT table_name FROM user_tables"
			try(ResultSet set = connection.createStatement().executeQuery("SELECT table_name FROM user_tables"))
			{
				while(set.next())
					System.out.println(set.getString(1));
			}
			catch(SQLException e)
			{
				e.printStackTrace();
			}
		}
		catch(SQLException e)
		{
			e.printStackTrace();
		}
	}
}