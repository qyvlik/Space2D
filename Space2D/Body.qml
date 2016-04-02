import QtQuick 2.4
import Space2D 0.1

Rectangle {
    id: body
    width: 30
    height: 30
//    transformOrigin: Item.Center
    color: Qt.rgba(Math.random(),Math.random(),Math.random(),1)

    signal refresh
    property var listenBodies: []
    function addListBodyList(bodyList){
        for(var i=bodyList.length-1; i>=0; i--){
            listenBodies.push(bodyList[i]);
        }
    }

    property int shapeType: Space2D.unknowType
    property int bodyType: Space2D.itemType

    readonly property vector2d center: Qt.vector2d(x+width/2, y+height/2);

    // 合外力
    property vector2d force: Qt.vector2d(0,0) // N
    function joinForce(f){ force = force.plus(f); }

    readonly property vector2d acceleration: force.times(1 / mass) // 加速度

    property real mass: 1 // g
    property vector2d velocity: Qt.vector2d(0,0) // 速度 // pix / s
    property vector2d nextPoint

    onForceChanged: refresh();

    onRefresh:  {
        __move();
    }

    function __move(){
        velocity = acceleration.times(Space2D.timeStep).plus(velocity);

        // velocity.length() * timeStep < 1 ;
        //
        nextPoint = nextPoint.plus(velocity.times(Space2D.timeStep));
    }

    onNextPointChanged: {
        x = nextPoint.x;
        y = nextPoint.y;
    }
}

