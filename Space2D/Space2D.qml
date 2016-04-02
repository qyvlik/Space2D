pragma Singleton
import QtQuick 2.0

QtObject {
    id: space2D

    // shape Type
    readonly property int unknowType: -1
    readonly property int circleType: 0
    readonly property int polygonType: 3
    readonly property int rectangleType: 4

    // body type
    readonly property int itemType: 0
    readonly property int rigidType: 1
    readonly property int staticType: 2

    readonly property real timeStep: 0.01
    readonly property real maxVelocity: 3 / timeStep

    signal refresh

    property Timer timer : Timer{
        id: timer
        interval: timeStep * 1000
        repeat: true
        running: true
        onTriggered: refresh();
    }

    function pause(){
        timer.stop();
    }

    function start(){
        timer.start();
    }

    function createVelocity(x, y){
        var v = Qt.vector2d(x, y);
        if(v.length() > maxVelocity){
            v = v.normalized().times(maxVelocity);
        }
        //console.log(v);
        return v;
    }


    signal createBodyFinished(var body)
    function createBody(space, bodyType, shapeType, properties){
        var url = "./Body.qml";
        if(bodyType !== staticType){
            switch(shapeType){
            case unknowType:
                break;
            case circleType:
                url = "./CircleBody.qml";
                break;
            case polygonType:
                url = "./PolygonBody.qml";
                break;
            case rectangleType:
                url = "./RectBody.qml";
                break;
            default:break;
            }
        } else {
            url = "./StaticBody.qml";
        }
        var component = Qt.createComponent(url);
        console.assert(component,"component created failedly");
        var incubator = component.incubateObject(space, properties);
        console.assert(!objectIsNull(incubator));
        if(!objectIsNull(incubator)){
            if (incubator.status != Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status == Component.Ready) {
                        createBodyFinished(incubator.object);
                    }
                }
            } else {
                createBodyFinished(incubator.object);
            }
            // indeed
            incubator.forceCompletion();
        }else {
            createBodyFinished(incubator.object);
        }
    }

    function objectIsNull(object){
        if (!object && typeof(object)!="undefined" && object != 0){
            return true;
        }
        return false;
    }

    function collide(item1, item2, shape_collide, collide_reaction){
        if(shape_collide(item1, item2)){
            collide_reaction(item1, item2);
        }
    }

    function cicular_collide(cir1, cir2){
        var o1 = cir1.center;
        var o2 = cir2.center;
        return o1.minus(o2).length() - (cir1.radius + cir2.radius) < 1;
    }

    function circular_completely_collide_reaction(cir1, cir2){
        // velocity
        // mass
        var m1 = cir1.mass;
        var v1 = cir1.velocity;
        var m2 = cir2.mass;
        var v2 = cir2.velocity;

        // 求 cir1 和 cir2 的碰撞面的单位法线
        var N = cir1.center.minus(cir2.center).normalized();

        // 求 v1 在 N 上正交分解
        var v1_paraller_N = N.times(v1.dotProduct(N));
        var v1_vertial_N = v1.minus(v1_paraller_N);

        // 求 v2 在 N 上正交分解
        var v2_paraller_N = N.times(v2.dotProduct(N));
        var v2_vertial_N = v2.minus(v2_paraller_N);


        // 在 N 方向上使用动量守恒以及动能守恒求出碰撞后的在N方向上的速度
        // 大小与N方向相同的取正，相反取负
        var v1_paraller_N_size, v2_paraller_N_size;
        var v1_reflect_paraller_N, v2_reflect_paraller_N;

        if(m1 !== m2) {
            if(vectorsHasSameDirection(v1_paraller_N, N))
                v1_paraller_N_size = v1_paraller_N.length();
            else
                v1_paraller_N_size = -v1_paraller_N.length();

            if(vectorsHasSameDirection(v2_paraller_N, N))
                v2_paraller_N_size = v2_paraller_N.length();
            else
                v2_paraller_N_size = -v2_paraller_N.length();

            if(v1_paraller_N_size === 0 ){
                v1_reflect_paraller_N = N.times(2*m2*v2_paraller_N_size / (m1+m2));
                v2_reflect_paraller_N = N.times((m1-m2)*v2_paraller_N_size / (m1+m2));
            } else if(v2_paraller_N_size === 0) {
                v1_reflect_paraller_N = N.times((m1-m2)*v1_paraller_N_size / (m1+m2));
                v2_reflect_paraller_N = N.times(2*m1*v1_paraller_N_size / (m1+m2));
            } else {
                v1_reflect_paraller_N = N.times(((m1-m2)*v1_paraller_N_size+2*m2*v2_paraller_N_size)/(m1+m2));
                v2_reflect_paraller_N = N.times((2*m1*v1_paraller_N_size+(m2-m1)*v2_paraller_N_size)/(m1+m2));
            }
        } else {
            v1_reflect_paraller_N = v2_paraller_N;
            v2_reflect_paraller_N = v1_paraller_N;
        }

        // 合并 N 以及 垂直 N 上的速度
        cir1.velocity = v1_reflect_paraller_N.plus(v1_vertial_N);
        cir2.velocity = v2_reflect_paraller_N.plus(v2_vertial_N);
    }

    function rectangles_collide(rect1, rect2){
        if( ((rect1.y+rect1.height) >= rect2.y)
                && (rect1.y <=( rect2.y+rect2.height)) ) {
            if( ((rect1.x+rect1.width) >= rect2.x)
                    && (rect1.x <=( rect2.x+rect2.width)) ) {
                return true;
            }
            return false;
        }
        return false;
    }

    // vector 2d utility function

    function vectorsHasSameDirection(vector1, vector2){
        if(vectorIsCollinear(vector1, vector2))
            if(vector1.x / vector2.x > 0 ) return true;
        return false;
    }

    function vectorIsCollinear(vector1, vector2){
        if(vector1.length() === 0 || vector2.length() === 0) return false;
        if(vector1.x / vector2.x === vector1.y / vector2.y)  return true;

        return false;
    }

    // 分解
    function vector2dResolve(v, N){
        var v_paraller_N, v_vertial_N;

        N = N.normalized();
        v_paraller_N = N.times(v.dotProduct(N));
        v_vertial_N = v.minus(v_paraller_N);

        return  [v_paraller_N,v_vertial_N];
    }

    // The reflection vector
    // 反射
    function vector2dReflect(v, N){
        // 第一步将 法向量N 转换为单位向量
        N = N.normalized();
        // 然后求-v在向量N上的投影长度的两倍 projectionLengthX2
        var lengthX2 = v.times(-1).dotProduct(N) * 2;
        // 将N乘以 projectionLengthX2 再加上v
        return N.times(lengthX2).plus(v);
    }

    function orthogonal_decompostion_N(v, N){
        var v_paraller_N, v_vertial_N;

        N = N.normalized();
        v_paraller_N = N.times(v.dotProduct(N));
        v_vertial_N = v.minus(v_paraller_N);

        return  [v_paraller_N,v_vertial_N];
    }
}

