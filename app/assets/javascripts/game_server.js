window.doit = function(){
  var WAITING_FOR_PLAYERS = 0,
      READY_TO_START = 1,
      RUNNING = 2;

  var pusher = new Pusher('ce0f7e9d17c0e1cf9eef');
  var state = WAITING_FOR_PLAYERS;
  var playersConnected = 0;
  var minPlayers = 2;
  var listSessionsInterval;

  startListingSessions();

  function setStatus(msg){
    $('#status').html(msg);
  }

  function startListingSessions(){
    if (playersConnected < minPlayers) {
      setWaitingForConnections();
    }
    listSessions();
    listSessionsInterval = window.setInterval(listSessions, 5000);

    function listSessions(){
      var $sessions = $('#sessions');
      $sessions.find('li').remove();
      $.getJSON('/game_server/active_sessions', function(data){
        playersConnected = data.length;
        if (state == WAITING_FOR_PLAYERS && playersConnected >= minPlayers) {
          setReadyToStart();
        } else {
          setWaitingForConnections();
        }
        $.each(data, function(key, session){
          var $session = $('<li/>');
          $session.attr('session-id', session._id);
          $session.html( session.name + ' - ' + session.mac_address );

          $sessions.append( $session );
        });
      });
    }
  }

  function stopListingSessions(){
    window.clearInterval( listSessionsInterval );
    listSessionsInterval = null;
  }

  function setReadyToStart(){
    setStatus('Ready to start');
    state = READY_TO_START;
    $('#start-game').removeAttr('disabled');
    $('#start-game').unbind('click').bind('click', startGame);
  }

  function setWaitingForConnections(){
    setStatus('Waiting for connections');
    state = WAITING_FOR_PLAYERS;
    $('#start-game').attr('disabled', 'disabled');
  }

  function startGame(){
    state = RUNNING;
    $('#start-game').attr('disabled', 'disabled');
    stopListingSessions();
    $.get('/game_server/start_game');
  }
}
