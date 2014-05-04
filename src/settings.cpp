#include <QtCore>
#include <QSettings>
#include <QVariant>
#include <QVariantList>
#include "settings.h"

Settings::Settings(QObject *parent) :
    QObject(parent), _setup(NULL)
{

//    this->setCurrentCity( this->_setup.value("currentCity", "").toString());
//    this->setTempUnit( this->_setup.value("tempUnit", QString::fromUtf8("°C")).toString());
//    this->setRefreshRate( this->_setup.value("refreshRate", 1000*60*30).toInt());
//    this->setAutoRefreshOn( this->_setup.value("autoRefreshOn", true).toBool());
}

void Settings::storeSettings()
{
//    this->_setup.setValue("currentCity", this->_current_city);
//    this->_setup.setValue("tempUnit", this->_temp_unit);
//    this->_setup.setValue("refreshRate",this->_refresh_rate);
//    this->_setup.setValue("autoRefreshOn",this->_auto_refresh_on);
    if(this->_setup)
    {
        this->_setup->sync();
    }

}

void Settings::setupConfig(QString folder, QString file)
{
    if(this->_setup == NULL)
    {
        this->_setup = new QSettings(folder, file, this);
    }
}

void Settings::writeSetting(QString name, QVariant value)
{
    if(this->_setup)
    {
        this->_setup->setValue(name, value);
    }
}

QVariant Settings::readSetting(QString name, QVariant def, ConvertType prefType)
{
    if(this->_setup)
    {
        return this->convertToType(this->_setup->value(name, def), prefType);
    }
    else
    {
        return "ERR";
    }
}

void Settings::writeSettingsArray(QString arrayName, QVariantList settings)
{
    this->_setup->remove(arrayName);
    this->_setup->beginWriteArray(arrayName);

    for(int i = 0; i < settings.size(); ++i)
    {
        this->_setup->setArrayIndex(i);
        this->_setup->setValue("val", settings.at(i));
    }
    this->_setup->endArray();
}

QVariantList Settings::readSettingsArray(QString arrayName, ConvertType prefType)
{
    QVariantList temp;

    int size = this->_setup->beginReadArray(arrayName);
    for(int i = 0; i < size; ++i)
    {
        this->_setup->setArrayIndex(i);
        temp.append(this->convertToType(this->_setup->value("val"), prefType));
    }
    this->_setup->endArray();
    return temp;
}

QVariant Settings::convertToType(QVariant input, ConvertType type)
{
    switch(type)
    {
    case Settings::Int:
        return input.toInt();
        break;
    case Settings::Bool:
        return input.toBool();
        break;
    case Settings::String:
        return input.toString();
        break;
    case Settings::Double:
        return input.toDouble();
        break;
    default:
        return input;
        break;
    }
}

