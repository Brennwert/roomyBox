/**
*    Copyright (C) 2016 Markus Wolf <roomybox@wolf.place>
*
*    This file is part of roomyBox.
*
*    roomyBox is free software: you can redistribute it and/or  modify
*    it under the terms of the GNU Affero General Public License, version 3,
*    as published by the Free Software Foundation.
*
*    roomyBox is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU Affero General Public License for more details.
*
*    You should have received a copy of the GNU Affero General Public License
*    along with roomyBox.  If not, see <http://www.gnu.org/licenses/>.
*/


function KelvinToCelsius (kelvin) {
	return Math.round(kelvin - 273.15) + '°C';
}

function weekday (unixtime) {
	return moment.unix(unixtime).locale(language).format('dd');
}

var Weather = React.createClass({

	apiGet: function(type, cnt) {
	  $.ajax({
        url: 'http://api.openweathermap.org/data/2.5/' + type + '?q=' + weatherLocation + '&APPID=' + weatherApiKey + '&lang=' + language + '&cnt=' + cnt,
        dataType: 'json',
        cache: false,
        success: function(data) {
        	type = type.replace(/(.*)\/(.*)/, "$1$2");
        	var response  = {};
  			response[type] = data;
         	this.setState(response);
        }.bind(this)
      });
	},

	weatherDetail: function(index) {
		// Open popup-overlay:
		$('#overlay').show();
		$('#popup').fadeIn();

		// Loop through forecast and add all relevant hourly entries:
		var date = moment.unix(this.state.forecastdaily.list[index].dt).format('YYYYMMDD');

		var hourlyList = this.state.forecast.list;
		var hourly = [];
		for (var i = 0; i < hourlyList.length; i++) {
		    if ( date == moment.unix(hourlyList[i].dt).format('YYYYMMDD') ) {
		    	hourly.push(hourlyList[i]);
		    }
		}

		this.setState({
				detail: {
					index: index,
					hourly: hourly,
				},
		});
	},

	getInitialState: function() {
	  return { 
	  	weather: { weather: [{}], main: {} },
	  	forecastdaily: { list: [ { weather: [{}] } ] },
	  	detail: { index: 0, hourly: [{ main: {}, weather: [{}] }] },
	  };
	},

	componentDidMount: function() {
      setInterval(this.apiGet('weather'), this.props.pollInterval);
      setInterval(this.apiGet('forecast'), this.props.pollInterval);
      setInterval(this.apiGet('forecast/daily', weatherDays), this.props.pollInterval);
	},

	render: function() {

		var that = this;

		var forecast = this.state.forecastdaily.list.map(function(entry, i) {

			// Skip today (first entry):
			if (i == 0) {
				return '';
			}

	        return <div className="weatherBox" onClick={() => that.weatherDetail( i ) }>
	        			<img src={"/gfx/weather/" + entry.weather[0].icon + ".png"} className="weatherIcon" />
	        			<span className="weekday">{ weekday(entry.dt) }</span>
	        			<div className="temp">
	        				{ KelvinToCelsius(entry.temp.max) }
	        				<br />
	        				{ KelvinToCelsius(entry.temp.min) }
	        			</div>
	        			<div className="conditionText">
	        				{entry.weather[0].description}
	        			</div>
        			</div>;
      	});

		var hourly = this.state.detail.hourly.map(function(entry, i) {
    		return <div className="hourlyLine">
    					<div className="timeHourly">{moment.unix(entry.dt).format('HH:mm')}:</div>
    					<div className="tempHourly">{KelvinToCelsius(entry.main.temp)}</div>
    					<img className="weatherIconSmall" src={"/gfx/weather/" + entry.weather[0].icon + ".png"} />
    					<div className="conditionTextHourly">{entry.weather[0].description}</div>
					</div>;
    	});

	  	return 	<div>
		  			<div className="weatherBox weatherBoxToday" onClick={() => this.weatherDetail( 0 ) }>
			          <img src={"/gfx/weather/" + this.state.weather.weather[0].icon + ".png"} className="weatherIcon" />
			          <span className="weekday">{ weekday(this.state.weather.dt) }</span>
			          <div className="temp">
			          { KelvinToCelsius(this.state.weather.main.temp) }
			          </div>
			          <br />
			          <div className="conditionText">
			          	{ this.state.weather.weather[0].description }
			          </div>
			        </div>
			        {forecast}

			        <div id="popup">
			        	<h2>{ moment.unix( this.state.forecastdaily.list[this.state.detail.index].dt ).locale(language).format('dddd') }</h2>
			        	{hourly}
			        	<br />
			        </div>
	      		</div>;
	}

});



ReactDOM.render(
	<Weather pollInterval={120000} />,
	document.getElementById('weatherContainer')
);