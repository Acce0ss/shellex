#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QVariant>
#include <QVariantList>

class QSettings;

class Settings : public QObject
{
    Q_OBJECT

    Q_ENUMS(ConvertType)

    //property int refreshRate: 1000*60*10
//    property bool autoRefreshOn: false
//    property string tempUnit: "°C"

public:
    explicit Settings(QObject *parent = 0);

    enum ConvertType {String, Int, Bool, Double};

signals:
    void settingsStored();
public slots:

    void storeSettings();
    void setupConfig(QString folder, QString file);

    void writeSetting(QString name, QVariant value);

    QVariant readSetting(QString name, QVariant def, ConvertType prefType);

    void writeSettingsArray(QString arrayName, QVariantList settings);
    QVariantList readSettingsArray(QString arrayName, ConvertType prefType);
private:
    QVariant convertToType(QVariant input, ConvertType type);

    QSettings* _setup;

};

#endif // SETTINGS_H
