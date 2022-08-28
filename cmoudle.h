#ifndef CMOUDLE_H
#define CMOUDLE_H

#include <QObject>

class CMoudle : public QObject
{
    Q_OBJECT

    // 注册，使之可以在QML中调用
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)

public:
    explicit CMoudle(QObject *parent = nullptr);
    // name some1
    void setName(const QString &name);
    QString getName() const;

signals:
    // name some2
    void nameChanged(const QString name);

public slots:
    void println(QString text);

private:
    // 类私属性
    // name some3 other
    QString myName;
};

#endif // CMOUDLE_H
