package com.alokkumar;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Scanner;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

@WebServlet("/MyServlet")
public class MyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public MyServlet() {
        super();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String city = request.getParameter("userInput");

        if (city == null || city.trim().isEmpty()) {
            request.setAttribute("error", "City name cannot be empty.");
            request.getRequestDispatcher("index.jsp").forward(request, response);
            return;
        }

        city = city.trim();
        String encodedCity = URLEncoder.encode(city, "UTF-8");

        String apiKey = "7f7774346a16d1d9c9a603db24c04455";
        String apiURL = "https://api.openweathermap.org/data/2.5/weather?q=" + encodedCity + "&appid=" + apiKey + "&units=metric";

        try {
            URL url = new URL(apiURL);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");

            int responseCode = connection.getResponseCode();

            if (responseCode == 200) {
                InputStream inputStream = connection.getInputStream();
                InputStreamReader reader = new InputStreamReader(inputStream);
                Scanner sc = new Scanner(reader);
                StringBuilder sb = new StringBuilder();

                while (sc.hasNext()) {
                    sb.append(sc.nextLine());
                }
                sc.close();

                // Parse JSON
                Gson gson = new Gson();
                JsonObject jsonObject = gson.fromJson(sb.toString(), JsonObject.class);

                // Extract data
                String cityName = jsonObject.get("name").getAsString();
                JsonObject sys = jsonObject.getAsJsonObject("sys");
                String country = sys.get("country").getAsString();

                JsonObject main = jsonObject.getAsJsonObject("main");
                double temperature = main.get("temp").getAsDouble();
                double feelsLike = main.get("feels_like").getAsDouble();
                int humidity = main.get("humidity").getAsInt();

                JsonObject wind = jsonObject.getAsJsonObject("wind");
                double windSpeed = wind.get("speed").getAsDouble();

                String weatherCondition = jsonObject.getAsJsonArray("weather")
                        .get(0).getAsJsonObject()
                        .get("main").getAsString();

                long dt = jsonObject.get("dt").getAsLong(); // UTC time in seconds
                int timezone = jsonObject.get("timezone").getAsInt(); // Offset in seconds

                // ✅ Calculate local time using java.time API
                Instant utcInstant = Instant.ofEpochSecond(dt);
                ZoneOffset offset = ZoneOffset.ofTotalSeconds(timezone);
                ZonedDateTime cityTime = utcInstant.atOffset(offset).toZonedDateTime();
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
                String localTime = formatter.format(cityTime);

                // Set attributes for JSP
                request.setAttribute("city", cityName);
                request.setAttribute("country", country);
                request.setAttribute("temperature", temperature);
                request.setAttribute("feelsLike", feelsLike);
                request.setAttribute("humidity", humidity);
                request.setAttribute("windSpeed", windSpeed);
                request.setAttribute("weatherCondition", weatherCondition);
                request.setAttribute("localTime", localTime);
                request.setAttribute("weatherData", sb.toString());

                connection.disconnect();
                request.getRequestDispatcher("index.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "City not found or API error. Response code: " + responseCode);
                request.getRequestDispatcher("index.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.getWriter().append("Served at: ").append(request.getContextPath());
    }
}

