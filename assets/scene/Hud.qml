import QtQuick 2.2
import "hud"

Item {
    id:root
    anchors.fill: parent
    property alias power: power_bar.power
    property alias angle: angle_bar.angle
    property alias score0: score.score0
    property alias score1: score.score1
    property int phase: 0
    property var messages: ["",
                            "Select your position with UP and DOWN, then press SPACE",
                            "Press SPACE to validate your direction",
                            "Press SPACE to release your power",
                            "Press UP and DOWN to sweep !",
                            "Enjoy your dexterity",
                            ""]

    PowerBar{
        id: power_bar
        anchors.horizontalCenter: parent.horizontalCenter
        y: 650
    }

    AngleBar{
        id: angle_bar
        anchors.horizontalCenter: parent.horizontalCenter
        y: 525
    }

    Winner{
        id: winner_screen
        visible: false
    }

    Score{
        id: score
        anchors.verticalCenter: parent.verticalCenter
        x: 1050
    }

    KeyDisplay{
        anchors.verticalCenter: power_bar.verticalCenter
        anchors.left: power_bar.right
        anchors.leftMargin: 50
        text:"→"
        visible: false
    }
    KeyDisplay{
        anchors.verticalCenter: power_bar.verticalCenter
        anchors.right: power_bar.left
        anchors.rightMargin: 50
        text:"←"
        visible: false
    }

    Text{
        id: indications
        text: root.messages[phase]
        y:50
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: "PaintyPaint"
        font.pixelSize: 28
    }

    function show_winner(){
        winner_screen.team = root.score0 > root.score1 ? 0 : 1
        winner_screen.visible = true
    }

    function initialize(){
        winner_screen.visible = false
        root.score0 = 0
        root.score1 = 0
    }
}

