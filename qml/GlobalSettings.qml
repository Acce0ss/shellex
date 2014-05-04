import QtQuick 2.0
import harbour.shellex 1.0

Settings {
    id: root

    property int timesHintShown

    Component.onCompleted: {
        setupConfig("harbour-shellex", "harbour-shellex");

        timesHintShown = readSetting("timesHintShown", 0, Settings.Int);

    }

    onTimesHintShownChanged: {
        writeSetting("timesHintShown", timesHintShown);
    }

    Component.onDestruction: {
        storeSettings();
    }
}
