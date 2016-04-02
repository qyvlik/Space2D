import Space2D 0.1
import QtQuick 2.4

Body {
    id: cir
    shapeType: Space2D.circleType
    radius: 15
    width : radius * 2
    height : radius * 2
    onRefresh: {
        if(bodyType === Space2D.rigidType){
            var i=0,len ;
            Space2D.pause();
            for(i=0, len = listenBodies.length; i<len; i++){
                Space2D.collide(cir,
                                listenBodies[i],
                                Space2D.cicular_collide,
                                Space2D.circular_completely_collide_reaction);
            }
            Space2D.start();
        }
    }
//    Text{
//        anchors.centerIn: parent
//        text:"("+cir.x+", "+cir.y+")";
//    }
}

