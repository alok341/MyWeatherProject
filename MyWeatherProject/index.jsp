<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Weather App</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: url("images/giphy.gif") no-repeat center center fixed;
            background-size: cover;
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding-top: 50px;
            min-height: 100vh;
        }

        .container {
            background-color: rgba(0, 0, 0, 0.65);
            padding: 40px 30px;
            border-radius: 15px;
            width: 90%;
            max-width: 450px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
            text-align: center;
            animation: fadeIn 1s ease-in-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .weather-icon img {
            width: 100px;
            height: 100px;
            animation: bounceIn 0.6s;
        }

        @keyframes bounceIn {
            0% { transform: scale(0.5); opacity: 0; }
            60% { transform: scale(1.2); opacity: 1; }
            100% { transform: scale(1); }
        }

        .weather-info {
            margin-top: 20px;
        }

        .weather-info h2 {
            margin-bottom: 15px;
            font-size: 26px;
        }

        .detail {
            margin: 8px 0;
            font-size: 16px;
        }

        .input-form, .search-history {
            margin-top: 25px;
        }

        button, input[type="text"] {
            padding: 12px;
            border-radius: 8px;
            border: none;
            font-size: 15px;
            margin-top: 10px;
        }

        button {
            background-color: #ffffff;
            color: #333;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.2s ease;
        }

        button:hover {
            background-color: #dddddd;
            transform: scale(1.05);
        }

        input[type="text"] {
            width: 100%;
            max-width: 250px;
        }

        ul {
            list-style: none;
            padding: 0;
            margin-top: 10px;
        }

        li {
            background-color: rgba(255, 255, 255, 0.1);
            margin: 5px 0;
            padding: 8px 10px;
            border-radius: 6px;
            font-size: 14px;
        }

        @media (max-width: 480px) {
            .container {
                padding: 25px 20px;
                font-size: 14px;
            }

            .weather-info h2 {
                font-size: 22px;
            }

            input[type="text"], button {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <c:if test="${not empty city}">
            <div class="weather-icon">
                <img id="weatherImg" src="" alt="Weather Icon" />
            </div>

            <div class="weather-info">
                <h2>${city}, ${country}</h2>
                <div class="detail"><strong>Temperature:</strong> ${temperature} °C</div>
                <div class="detail"><strong>Feels Like:</strong> ${feelsLike} °C</div>
                <div class="detail"><strong>Humidity:</strong> ${humidity} %</div>
                <div class="detail"><strong>Wind Speed:</strong> ${windSpeed} km/h</div>
                <div class="detail"><strong>Condition:</strong> ${weatherCondition}</div>
                <div class="detail"><strong>Local Time:</strong> ${localTime}</div>
            </div>

            <input type="hidden" id="condition" value="${weatherCondition}">
        </c:if>

        <div class="input-form">
            <form action="MyServlet" method="post">
                <input name="userInput" type="text" placeholder="Enter City Name" required />
                <button type="submit">Check Weather</button>
            </form>
        </div>

        <div class="search-history">
            <h3>Search History</h3>
            <ul id="historyList"></ul>
        </div>
    </div>

    <script>
        const condition = document.getElementById("condition")?.value;
        const weatherImg = document.getElementById("weatherImg");
        const iconMap = {
            "Clear": "https://cdn-icons-png.flaticon.com/512/6974/6974833.png",
            "Clouds": "https://cdn-icons-png.flaticon.com/512/414/414825.png",
            "Rain": "https://cdn-icons-png.flaticon.com/512/3351/3351979.png",
            "Snow": "https://cdn-icons-png.flaticon.com/512/642/642102.png",
            "Mist": "https://cdn-icons-png.flaticon.com/512/4005/4005901.png",
            "Haze": "https://cdn-icons-png.flaticon.com/512/1197/1197102.png",
            "Drizzle": "https://cdn-icons-png.flaticon.com/512/1163/1163624.png",
            "Thunderstorm": "https://cdn-icons-png.flaticon.com/512/1146/1146869.png"
        };

        if (weatherImg && iconMap[condition]) {
            weatherImg.src = iconMap[condition];
        } else if (weatherImg) {
            weatherImg.src = "https://cdn-icons-png.flaticon.com/512/1163/1163624.png";
        }

        // Search History - using localStorage
        const form = document.querySelector('form');
        const input = form.querySelector('input[name="userInput"]');
        const historyList = document.getElementById('historyList');

        function updateHistory(city) {
            let history = JSON.parse(localStorage.getItem('weatherHistory')) || [];
            if (!history.includes(city)) {
                history.unshift(city);
                if (history.length > 5) history.pop();
                localStorage.setItem('weatherHistory', JSON.stringify(history));
            }
            renderHistory();
        }

        function renderHistory() {
            let history = JSON.parse(localStorage.getItem('weatherHistory')) || [];
            historyList.innerHTML = '';
            history.forEach(city => {
                const li = document.createElement('li');
                li.textContent = city;
                li.style.cursor = 'pointer';
                li.onclick = () => {
                    input.value = city;
                    form.submit();
                };
                historyList.appendChild(li);
            });
        }

        <% if (request.getAttribute("city") != null) { %>
        updateHistory("<%= request.getAttribute("city") %>");
        <% } %>

        renderHistory();
    </script>
</body>
</html>
