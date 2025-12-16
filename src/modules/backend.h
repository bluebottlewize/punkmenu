#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QVariantList>

class Backend : public QObject {
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr) {};

    Q_INVOKABLE void runCommand(const QString &cmd);
    Q_INVOKABLE QVariantList loadConfig();
};

#endif // BACKEND_H
