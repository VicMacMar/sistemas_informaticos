import java.sql.*;

public class Main {

    private static String url = "jdbc:mysql://bd-sistemas-victor.czq8w08qo6ov.us-east-1.rds.amazonaws.com:3306/clase?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static String user = "admin";
    private static String password = "Victor.macian88";

    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("Driver cargado correctamente");
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("URL usada: ["+url+"]");

            Connection con = DriverManager.getConnection(url, user, password);
            System.out.println("Conexión establecida");

            Statement st = con.createStatement();
            ResultSet rs = st.executeQuery("SELECT * FROM profesores");

            while (rs.next()) {
                int id = rs.getInt("id");
                String nombre = rs.getString("nombre");
                String departamento = rs.getString("departamento");
                String email = rs.getString("email");

                System.out.println(id+" - "+nombre+" - "+departamento+" - "+email);
            }
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
