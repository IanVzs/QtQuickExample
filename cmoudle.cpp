#include "cmoudle.h"
#include <QDebug>

CMoudle::CMoudle(QObject *parent) : QObject(parent),
    myName("none")
{
}

void CMoudle::println(QString text)
{
        qDebug() <<  "Println: " << text;
//        setName(text);
}

void CMoudle::setName(const QString &name)
{
        qDebug() << "setName: " << name;
        if (myName != name) {
            qDebug() << "emit nameChanged";
            myName = name;
            emit nameChanged(name);
        }

}
QString CMoudle::getName() const
{
    qDebug() << "getName: " << myName;
    return myName;
}
