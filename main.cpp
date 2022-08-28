#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "cmoudle.h"


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    // 注册C++ class到QML
    // 参数：qmlRegisterType<C++类型名> (import时模块名 主版本号 次版本号 QML中的类型名)
    qmlRegisterType<CMoudle>("CMoudle.moudle", 1, 0, "CMdle");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
