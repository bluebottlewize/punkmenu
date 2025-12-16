#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QProcess>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>
#include <QCoreApplication>

#include "backend.h"

void Backend::runCommand(const QString &cmd) {
    qDebug() << "Executing:" << cmd;
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << cmd);
    // QCoreApplication::quit();
}

static QString normalizeImage(const QString &path)
{
    if (path.startsWith("/"))
        return "file://" + path;
    return path;
}

static QJsonArray loadJsonArray(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return {};

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    return doc.isArray() ? doc.array() : QJsonArray{};
}

static QVariantMap mergeConfigs(
    const QJsonObject &base,
    const QJsonObject &override)
{
    QVariantMap result;

    auto get = [&](const char *key) -> QVariant {
        if (override.contains(key))
            return override.value(key).toVariant();
        return base.value(key).toVariant();
    };

    result["name"] = get("name");
    result["cmd"]  = get("cmd");

    result["imgInactive"] =
        normalizeImage(get("imgInactive").toString());

    result["imgActive"] =
        normalizeImage(get("imgActive").toString());

    qDebug() << result["imgActive"].toString();

    return result;
}

QVariantList Backend::loadConfig()
{
    QVariantList buttons;

    // 1. Load default config (always)
    QJsonArray baseArray =
        loadJsonArray(":/assets/config.json");

    // 2. Load user config (optional)
    QString userPath = QStandardPaths::writableLocation(
                           QStandardPaths::ConfigLocation)
                       + "/punkmenu/config.json";

    QJsonArray userArray;
    if (QFile::exists(userPath)) {
        qDebug() << "Loading user config:" << userPath;
        userArray = loadJsonArray(userPath);
    } else {
        qDebug() << "User config missing, using defaults only.";
    }

    // 3. Merge per index
    const int count = baseArray.size();
    for (int i = 0; i < count; ++i) {
        QJsonObject baseObj = baseArray[i].toObject();
        QJsonObject userObj;

        if (i < userArray.size())
            userObj = userArray[i].toObject();

        buttons.append(mergeConfigs(baseObj, userObj));
    }

    return buttons;
}
