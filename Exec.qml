import QtQuick 2.0

QtObject {
    signal exec
    Component.onCompleted: exec();
}

