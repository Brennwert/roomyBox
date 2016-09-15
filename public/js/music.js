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


// Current track controller & display (left side of widget):
var CurrentTrack = React.createClass({

	loadCurrentTrack: function() {
	  $.ajax({
	    url: '/music/currentTrack',
	    dataType: 'json',
	    cache: false,
	    success: function(data) {
	      this.setState({currentTrack: data});
	    }.bind(this),
	    error: function(xhr, status, err) {
	      console.error('currentTrack', status, err.toString());
	    }.bind(this)
	  });
	},

	ctrlClick: function (url, action) {
	  if (typeof action != 'undefined') {
	    this.state.currentTrack.State = action;
	    this.setState( {'currentTrack' : this.state.currentTrack } );
	  }

	  $.ajax({
	    url: url,
	    dataType: 'json',
	    cache: false,
	    success: function(data) {
	      //this.setState({currentTrack: data});
	    }.bind(this),
	    error: function(xhr, status, err) {
	      console.error(url, status, err.toString());
	    }.bind(this)
	  });

	},

	getInitialState: function() {
	  return { 
	    currentTrack: {},
	  };
	},

	componentDidMount: function() {
	  this.loadCurrentTrack();
	  setInterval(this.loadCurrentTrack, this.props.pollInterval);
	},

	render: function() {
	  var playClass = 'ctrl fa fa-play';
	  var pauseClass = 'ctrl fa fa-pause';

	  if ( this.state.currentTrack.State == 'PLAY' ) {
	    playClass += ' ctrlActive';
	  } else if ( this.state.currentTrack.State == 'PAUSE' ) {
	    pauseClass += ' ctrlActive';
	  }

	  return (
	    <div className="CurrentTrack">

	      <div id="currentTitle">{this.state.currentTrack.Title}</div><div id="timeLeft">{this.state.currentTrack.TimeLeft}</div>
	    
	      <div id="trackCtrl" className="clear">
	        <i className={playClass} aria-hidden="true" onClick={() => { this.ctrlClick( '/music/play', 'PLAY') } } />
	        <i className={pauseClass} aria-hidden="true" onClick={() => { this.ctrlClick( '/music/pause', 'PAUSE') } } />

	        <i className="ctrl fa fa-backward" aria-hidden="true" onClick={() => { this.ctrlClick( '/music/prev') } } />
	        <i className="ctrl fa fa-forward" aria-hidden="true" onClick={() => { this.ctrlClick( '/music/next') } } />
	        <i className="ctrl fa fa-repeat" aria-hidden="true" onClick={() => { this.ctrlClick( '/music/repeat') } } />

	        <div id="ctrlVolumeWrapper">
		        <i className="ctrlTiny fa fa-volume-up" aria-hidden="true" />
		        <div id="ctrlVolume"></div>
	        </div>
	        
	      </div>
	    </div>
	  )
	}
});

// File-list controller & display (right side of widget):
var TrackList = React.createClass({

	loadList: function(path) {
	  $.ajax({
	    url: '/music/trackList',
	    data: 'path=' + encodeURIComponent(path),
	    dataType: 'json',
	    cache: false,
	    success: function(data) {
	      this.setState({trackList: data.list});
	      this.setState({directory: data.directory});
	    }.bind(this)
	  });
	},

	playFile: function(path) {
	  $.ajax({
	    url: '/music/play',
	    data: 'path=' + encodeURIComponent(path),
	    dataType: 'json',
	    cache: false,
	    success: function(data) {
	      
	    }.bind(this)
	  });
	},

	entryClick: function (path, type) {

	  if (type == '..') {

	    // Jump up:
	    path = path.replace(/^(.*)\/.*/, "$1");
	    this.loadList(path);

	  } else if (type == 'd') {

	    // Load new list for clicked directory:
	    this.loadList(path);

	    /* 
	      TODO: Would be smoother if'd only scroll to top in subdirs. 
	      How to access state in this component function? 
	      if (this.state.directory.isRoot == 0) {}
	    */
	    $("#trackList").animate({ scrollTop: 0 }, "fast");

	  } else if (type == 'f') {
	    
	    // Play file:
	    this.playFile(path);

	  }
	},

	getInitialState: function() {
	  return { 
	    trackList: [],
	    directory: {},
	  };
	},

	componentDidMount: function() {
	  this.loadList();
	},

	render: function() {
	  var that = this;
	  var list = this.state.trackList.map(function(entry) {

	    var type = entry.type == 'f' ? '/gfx/music/icon_file.png' : '/gfx/music/icon_dir.png';

	    return <div className="trackListEntry" onClick={() => that.entryClick( entry.path, entry.type ) }><img src={type} /> {entry.name}</div>;
	  });

	  var jumpUp = '';
	  if (this.state.directory.isRoot == 0) {
	    jumpUp = <div className="trackListEntry" onClick={() => this.entryClick( this.state.directory.path, '..' ) }><img src="/gfx/music/arrowBack.png" /> <b><i>Zur&uuml;ck</i></b></div>;
	  }

	  return <div>
	            {jumpUp}
	            {list}
	          </div>;
	}

});



ReactDOM.render(
	<CurrentTrack pollInterval={1000} />,
	document.getElementById('currentTrack')
);


ReactDOM.render(
	<TrackList />,
	document.getElementById('trackList')
);



$( function() {
	$( "#ctrlVolume" ).slider({
		orientation: "horizontal",
		range: "min",
		max: 100,
		value: 80,
		change: function(event,ui) { 
			$.ajax({
				url: '/music/setVolume?arg=' + $(this).slider("value"),
				dataType: 'json',
				cache: false,
				success: function(data) {

				}.bind(this)
  			});
		},
	});
});