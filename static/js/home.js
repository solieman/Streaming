console.log('Home page loaded...');

let userId = null;
let globalVar = 0;
let roomId = null;

$(document).ready(function() {
  // Get my ID
  // $("#rooms-list").show();

  $.get("/myId", null, (response) => {
    userId = response || "Loading...";
    $("#x_player").text(userId);
  });

  getAllData();
  getAllPlayers();
  getAllRooms();

  // Subscribe to the streaming
  subscribe();

  $("#btn-play-new-game").click( () => {
    const selectedOpponnent = $("#select-player").val();

    if ( selectedOpponnent === userId) {
      alert("choose someone else!");
    } else {
      $.post("/newRoom/", {oPlayer: selectedOpponnent} , (response) => {
        getAllRooms()
      });
    }

  });

  $(".btn-send-data-to-server").click(() => {
    sendMessageToTheServer();
  });

  $('#dataInput').bind("enterKey",function(e){
     sendMessageToTheServer();
  });
  $('#dataInput').keyup(function(e){
      if(e.keyCode == 13)
      {
          $(this).trigger("enterKey");
      }
  });

// END of $(document).ready()
});

function subscribe() {
  $.get("/subscribe", null, (res) => {
    console.log('streaming response', res);
    if (res && res !== null && typeof(res) === 'object') {
      const responseData = JSON.parse(res);
      if (responseData.rId && responseData.rId !== null) {
        roomId = responseData.rId;
      } else {

      }
    }

    console.log(roomId);

    getAllData();
    // $("#all-data").append("<div>" + res + "</div>");
    subscribe();
  })
  .done(function(){

  });
}

function sendMessageToTheServer() {
  const newMessage = $("#dataInput").val();
  if (newMessage && newMessage !== null) {
    $.post("/message", {data: newMessage}, (response) => {
      $("#dataInput").val('');
      subscribe();

    });
  }
}

function getAllData(){
  $.get("/allAvailableMessages", null, (response) => {
    allAvailableMessages = response.data || "Loading...";

    getAllPlayers();

    // Render
    $("#all-data").empty();
    allAvailableMessages.forEach( (message) => {
      $("#all-data").append("<div>" + message.sender + " : " + message.message + "</div>");
    });
    $("#all-data").scrollTop = $("#all-data").scrollHeight;
  });
}

function getAllRooms(){
  $.get('/rooms', null, (response) => {
    console.log(response);
    allRooms = response.rooms || [];

    // Render
    $("#all-rooms-data").empty();
    allRooms.forEach( (room) => {
      $("#all-rooms-data").append("<div class='btn btn-info room-btn' onclick='getRoomData();' id='"
      + room.id
      + "'> <div class='room-btn-part'>"
      + room.xPlayer
      + "</div> VS <div class='room-btn-part'>"
      + room.oPlayer
      + "</div></div>");
    });
  });
}

function waitOtherPlayer(rooms_list) {
  return $.get("/waitOtherPlayer", null, (res) => {
    if (res && res != null) {
      return res;
    }
  });
}

function getAllPlayers() {
  $.get("/allplayers", null, (res) => {
    if (res && res.data && res != null) {
      $("#select-player").empty();
      res.data.forEach((item) => {
        if (userId !== item) {
          $("#select-player").append("<option value=" + item + ">" + item + "</option>");
        } else {
          $("#select-player").append("<option value=" + item + ">You </option>");
        }
      });
      //return res;
    }
  });
}

function getRoomData() {
    // get the room data from the server
    console.log(event.currentTarget.id)
    if (event.currentTarget.id && event.currentTarget.id !== null) {
      $.post("/roomData/", {id: event.currentTarget.id}, (response) => {
        console.log(response);
      });
    }
}

function removeRoomData() {
    // get the room data from the server
    console.log(event.currentTarget.id)
    if (event.currentTarget.id && event.currentTarget.id !== null) {
      $.post("/removeRoom/", {id: event.currentTarget.id}, (response) => {
        getAllRooms();
      });
    }
}
