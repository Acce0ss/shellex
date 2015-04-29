import QtQuick 2.0
import harbour.shellex 1.0

Settings {
    id: root

    property int timesHintShown
    property bool resetParameterComponents

    Component.onCompleted: {
      setupConfig("harbour-shellex", "harbour-shellex");

      timesHintShown = readSetting("timesHintShown", 0, Settings.Int);
      resetParameterComponents = false;

    }

    onTimesHintShownChanged: {
      writeSetting("timesHintShown", timesHintShown);
    }

    onResetParameterComponentsChanged: {
      writeSetting("resetParameterComponents", resetParameterComponents);
    }

    Component.onDestruction: {
      storeSettings();
    }
}
