import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import CMoudle.moudle 1.0

Window {
    id:root;        // Window元素的id，应该保证在这个qml文件中名字唯一
    visible: true;
    width: 460;     // 直接指定窗口的宽度
    height: 300;    // 直接指定窗口的高度

    Image {
        id: bg;
        width: parent.width;            // 图片的宽度依赖父窗口的宽度
        height: parent.height;          // 图片的高度依赖父窗口的高度
        source: "qrc:///images/sky.jpg" // 引用一张图片
    }

    Image {
        id: rocket;
        x: (parent.width - width) / 2;  // 图片位置水平居中
        y: 140; // 40;                          // 图片位置距离父窗口40
        source: "qrc:///images/rocket.png";
        NumberAnimation on y {
            from: rocket.y
            to: 0
            duration: 4000
            loops: Animation.Infinite
        }
        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 4000
            loops: Animation.Infinite
        }
    }

    Text {
        // 没有指定id，即这是一个匿名元素
        y: 300-50; //rocket.y + rocket.height + 20;                    // 文本顶部距离rocket图片底部20
        anchors.horizontalCenter: parent.horizontalCenter   // 设置文字水平居中
        text: qsTr("火箭发射！");                          // 设置文本显示的文字
        color: "#ffeebb";                                   // 设置文本颜色
        font.family: "楷体";                                // 设置字体为楷体
        font.pixelSize: 30;                                 // 设置文字大小
        MouseArea {
            width: parent.width
            height: parent.height
            onClicked: {
                console.log("666")
                rocket.visible = !rocket.visible
            }
        }
    }
    CusButton {
        id: button
        x: 12; y: 12
        text: "Start"
        onClicked: {
            button.text = "Button clicked!"
        }
    }
    // Button connect c++ moudle
    Button {
        id: button_CMdle
        x: 210; y: 12
        text: "Start"
    }
    CMdle {
        id: cmdle
//        nameChanged: {
//            button_CMdle.text = cmdle.name
//        }
        onNameChanged: {
            console.log("change by onNameChanged.")
            button_CMdle.text = cmdle.name
        }
    }
    Connections {
        target: button_CMdle
        onPressed: {
            console.log("fuck?");
            cmdle.println(input1.text);
            cmdle.nameChanged("niubia")
        }
        onReleased: {
            cmdle.name = input1.text
        }
    }
    // endconnect
    Rectangle {
        x: 60; y: 80
        width: 200; height: 80
        color: "linen"
        TextInput {
            id: input1
            x: 8; y: 8
            width: 96; height: 20
            focus: true
            text: "Text Input 1"
            KeyNavigation.tab: input2
        }
        TextInput {
            id: input2
            x: 8; y: 36
            width: 96; height: 20
            focus: true
            text: "copy input1"
            onFocusChanged: input2.text = input1.text;
            KeyNavigation.tab: input1
        }
    }
}
