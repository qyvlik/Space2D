import Space2D 0.1
import QtQuick 2.4
import QtQuick.Controls 1.2

Item{

    width: 500
    height: 400

    Space {
        id: space

        width: 500
        height: 400
        anchors.centerIn: parent

        StaticBody{
            id: topWall
            color: "red"
            bodyType: Space2D.staticType
            width: space.width
            height: 1
            anchors.top: space.top
            anchors.topMargin: 50
            reflect: Qt.vector2d(0,1)
        }

        StaticBody{
            id: bottomWall
            color: "red"
            bodyType: Space2D.staticType
            width: space.width
            height: 1
            anchors.bottom: space.bottom
            anchors.bottomMargin: 50
            reflect: Qt.vector2d(0,1)
        }

        StaticBody{
            id: rightWall
            color: "red"
            bodyType: Space2D.staticType
            height: space.height
            width: 1
            anchors.right: space.right
            anchors.rightMargin: 50
            reflect: Qt.vector2d(1,0)
        }

        StaticBody{
            id: leftWall
            color: "red"
            bodyType: Space2D.staticType
            height: space.height
            width: 1
            anchors.left: space.left
            anchors.leftMargin: 50
            reflect: Qt.vector2d(1,0)
        }

        Row{

            Button{
                text: "add a body"
                onClicked: {
                    space.addRigidBody(Space2D.circleType,
                                       {
                                           bodyType: Space2D.rigidType,
                                           nextPoint:Qt.vector2d(100,100),
                                           velocity:Space2D.createVelocity(100, 100)});
                }
            }
            Button{
                text: "add stop body"
                onClicked: {
                    space.addRigidBody(Space2D.circleType,
                                       {
                                           bodyType: Space2D.rigidType,
                                           nextPoint:Qt.vector2d(250,250),
                                           velocity:Qt.vector2d(0, 0)});
                }
            }
            Button{
                text: "pause"
                onClicked:Space2D.pause();
            }
            Button{
                text: "start"
                onClicked:Space2D.start();
            }
        }

        Exec{
            onExec: {

                space.addStaticBody(topWall);
                space.addStaticBody(bottomWall);
                space.addStaticBody(rightWall);
                space.addStaticBody(leftWall);

                space.addRigidBody(Space2D.circleType,
                                   {
                                       bodyType: Space2D.rigidType,
                                       nextPoint:Qt.vector2d(200,200),
                                       velocity:Qt.vector2d(100, 100)});
                space.addRigidBody(Space2D.circleType,
                                   {
                                       bodyType: Space2D.rigidType,
                                       nextPoint:Qt.vector2d(100,100),
                                       velocity:Qt.vector2d(10, 10)});

            }

        }
    }

}
/*
  QUnifiedTimer::stopAnimationDriver: driver is not running
*/
