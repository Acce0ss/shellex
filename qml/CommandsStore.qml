import QtQuick 2.0
import QtQuick.LocalStorage 2.0

import harbour.shellex 1.0

Item {
  id: root

  property ShellExecutor shell

  property var db

  //return pointer to added command if insert success
  function addCommand(jsonObj) {

    try {
      db.transaction( function (tx) {

        tx.executeSql("INSERT INTO commands(name,type,createdOn,lastRunOn,content,isInDatabase,runCount,runIn,linesMax)"
                      +" VALUES(?,?,?,?,?,?,?,?,?)",
                      [jsonObj.name, jsonObj.type, jsonObj.createdOn,
                       jsonObj.lastRunOn, jsonObj.content, 1, 0, jsonObj.runIn, 100]);

        var resultForId = tx.executeSql("SELECT id FROM commands WHERE name=?",[jsonObj.name]);

        jsonObj.id = resultForId.rows.item(0).id;

        jsonObj.isInDatabase = 1;
      });

      var created = shell.addCommandFromJSON(jsonObj);

      return created;
    }
    catch(e)
    {
      console.log("insert failed: " + e.message);
      return null;
    }
  }

  function updateCommand(commandObj)
  {
    var jsonObj = commandObj.getAsJSONObject();
    if(jsonObj.isInDatabase === true)
    {
      db.transaction( function(tx)
      {
        tx.executeSql("UPDATE commands SET name=?,type=?,content=?,runIn=? "
                      + " WHERE id=?",
                      [jsonObj.name, jsonObj.type,
                       jsonObj.content, jsonObj.runIn, jsonObj.id]
                      );
      } );

      shell.updateCommandById(jsonObj.id);
    }
    else
    {
      console.log("Error, command not in database");
    }
  }

  function updateCommandLastRunAndCount(commandObj)
  {
    var jsonObj = commandObj.getAsJSONObject();
    if(jsonObj.isInDatabase === true)
    {
      db.transaction( function(tx)
      {


        tx.executeSql("UPDATE commands SET lastRunOn=?,runCount=? WHERE id=?",
                      [jsonObj.lastRunOn,jsonObj.runCount,
                       jsonObj.id]
                      );


      } );

      shell.updateCommandById(jsonObj.id);
    }
    else
    {
      console.log("Error, command not in database");
    }
  }

  function updateCommandLinesMax(commandObj)
  {
    var jsonObj = commandObj.getAsJSONObject();
    if(jsonObj.isInDatabase === true)
    {
      db.transaction( function(tx)
      {


        tx.executeSql("UPDATE commands SET linesMax=? WHERE id=?",
                      [jsonObj.linesMax,
                       jsonObj.id]
                      );


      } );

    }
    else
    {
      console.log("Error, command not in database");
    }
  }

  function removeCommand(commandObj)
  {
    var jsonObj = commandObj.getAsJSONObject();
    if(jsonObj.isInDatabase === true)
    {
      db.transaction( function(tx)
      {

        tx.executeSql("DELETE FROM commands WHERE id=?",
                      [jsonObj.id]
                      );
      } );

      shell.removeCommandById(jsonObj.id);
    }
    else
    {
      console.log("Error, command not in database");
    }
  }

  function initModelsFromDB()
  {

    db.transaction( function(tx)
    {

      var result = tx.executeSql('SELECT id,name,type,isInDatabase,createdOn,lastRunOn,'
                                 +'content,runCount,runIn,linesMax FROM commands');

      var list = [];

      for(var i=0; i< result.rows.length; i++)
      {
        var obj = result.rows.item(i);

        list.push(obj);
      }

      shell.initFromJSONArray(list);
    }
    );
  }

  Component.onCompleted: {

    db = LocalStorage.openDatabaseSync("harbour-shellex", "",
                                       qsTr("Database for ShellEx commands and scripts")
                                       ,10000);

    switch( db.version )
    {
    case "0.1":

      try {
        console.log( "Upgrading database from version 0.1 to version 0.2...");
        db.changeVersion('0.1', '0.2', function(tx) {
          tx.executeSql('ALTER TABLE commands ADD COLUMN linesMax INTEGER NOT NULL DEFAULT 100');
          tx.executeSql('ALTER TABLE commands ADD COLUMN runIn TEXT NOT NULL DEFAULT "InsideApp"');
        });
      }catch(e)
      {
        console.log("database update failed: " + e.message);
        return;
      }

    case "0.2":
      console.log( "Upgrading database from version 0.2 to version 0.3...");
      try {
      db.changeVersion('0.2', '0.3', function(tx) {
        var result = tx.executeSql('SELECT id,content FROM commands');

        for(var i=0; i< result.rows.length; i++)
        {
          var obj = result.rows.item(i);

          var tempObj = {script: obj.content, parameters: []};

          tx.executeSql("UPDATE commands SET content=? WHERE id=?",
                        [JSON.stringify(tempObj),
                         obj.id]
                        );
        }
      });
      }catch(e)
      {
        console.log("database update failed: " + e.message);
        return;
      }

    case "0.3":
      //up to date and necessary tables exists
      console.log("Database up to date and ok...")
      initModelsFromDB();
      break;
    default:

      console.log("database didn't exists, create it and tables");
      db.changeVersion('', '0.3', function(tx)
      {
        tx.executeSql('CREATE TABLE IF NOT EXISTS commands('
                      + 'id INTEGER PRIMARY KEY AUTOINCREMENT,'
                      + 'name TEXT NOT NULL UNIQUE,'
                      + 'type TEXT NOT NULL DEFAULT "SingleLiner",'
                      + 'createdOn INTEGER NOT NULL,'
                      + 'lastRunOn INTEGER NOT NULL,'
                      + 'runCount INTEGER NOT NULL,'
                      + 'isInDatabase BOOLEAN NOT NULL,'
                      + 'content TEXT NOT NULL,' //needs to be json compliant string:
                      //{"script":"cp $1 $2","parameters":[{param1},{param2}, ...]}
                      //params have form of
                      //{"setupFilePath":"/path/to/*ParameterSetup.qml",
                      // "filePath": "/path/to/NameParameter.qml",
                      // "details":{"whatever":"it'svalue"},
                      // "display":"Display name"}
                      + 'runIn TEXT NOT NULL DEFAULT "InsideApp",'
                      + 'linesMax INTEGER NOT NULL DEFAULT 100'
                      + ')');
      });
      break;
    }
  }
}
