import QtQuick 2.0
import Space2D 0.1

Item {
    id: space
    width: 1200
    height: 650

    property var listenBodies: []
    property var staticBodies: []

    function addStaticBody(body){
        if(body)
            staticBodies.push(body);
    }

    function addRigidBody(shapeType, properties){
        Space2D.createBodyFinished.connect( function(body) {
            Space2D.createBodyFinished.disconnect(arguments.callee);
            listenBodies.push(body);
            body.addListBodyList(listenBodies); // 自添加监听刚体对象

            body.refresh.connect(function(){

                Space2D.pause();

                for(var len = staticBodies.length-1; len >= 0;len--){
                    Space2D.collide(body,
                                    staticBodies[len],
                                    function(item1,item2){
                                        if( ((item1.y+item1.height) >= item2.y)
                                                && (item1.y <=( item2.y+item2.height)) ) {
                                            if( ((item1.x+item1.width) >= item2.x)
                                                    && (item1.x <=( item2.x+item2.width)) ) {
                                                return true;
                                            }
                                            return false;
                                        }
                                        return false;
                                    },
                                    function(item1,item2){
                                        item1.velocity = Space2D.vector2dReflect(item1.velocity,item2.reflect);
                                    });
                }

                Space2D.start();

            });
            Space2D.refresh.connect(body.refresh);
        });
        Space2D.createBody(space, Space2D.rigidType, shapeType, properties);
    }
}

