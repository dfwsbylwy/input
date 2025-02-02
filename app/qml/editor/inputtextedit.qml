/***************************************************************************
 textedit.qml
  --------------------------------------
  Date                 : 2017
  Copyright            : (C) 2017 by Matthias Kuhn
  Email                : matthias@opengis.ch
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QgsQuick 0.1 as QgsQuick

/**
 * Text Edit for QGIS Attribute Form
 * Requires various global properties set to function, see featureform Loader section
 * Do not use directly from Application QML
 */
Item {
  signal valueChanged(var value, bool isNull)
  signal importDataRequested()
  property var rowHeight: customStyle.fields.height * 0.75
  property real iconSize: rowHeight
  property bool submitOnEditingFinished: field.isNumeric

  id: fieldItem
  enabled: !readOnly
  height: Math.max(textField.height, textArea.height)
  anchors {
    left: parent.left
    right: parent.right
  }

  TextField {
    id: textField
    height: textArea.height == 0 ? customStyle.fields.height : 0
    topPadding: 10 * QgsQuick.Utils.dp
    bottomPadding: 10 * QgsQuick.Utils.dp
    leftPadding: customStyle.fields.sideMargin
    rightPadding: textField.leftPadding + (importDataBtn.visible ? importDataBtn.width : 0)
    visible: height !== 0
    anchors.left: parent.left
    anchors.right: parent.right
    font.pointSize: customStyle.fields.fontPointSize
    color: customStyle.fields.fontColor

    text: value !== undefined ? value : ''
    inputMethodHints: field.isNumeric || widget === 'Range' ? Qt.ImhFormattedNumbersOnly : Qt.ImhNone

    // Make sure we do not input more characters than allowed for strings
    states: [
        State {
            name: "limitedTextLengthState"
            when: (!field.isNumeric) && (field.length > 0)
            PropertyChanges {
              target: textField
              maximumLength: field.length
            }
        }
    ]

    background: Rectangle {
        anchors.fill: parent
        border.color: textField.activeFocus ? customStyle.fields.activeColor : customStyle.fields.normalColor
        border.width: textField.activeFocus ? 2 : 1
        color: customStyle.fields.backgroundColor
        radius: customStyle.fields.cornerRadius
    }

    onEditingFinished: {
      if (fieldItem.submitOnEditingFinished) {
        valueChanged( text, text === undefined )
      }
    }

    onTextChanged: {
      if (!fieldItem.submitOnEditingFinished) {
        valueChanged( text, text === undefined )
      }
    }

    //! Commit value if has changed when widget gets out of the FeatureForm (ListView) viewport
    Component.onDestruction: {
      if ( textField.activeFocus ) {
        if ( value !== textField.text ) {
          valueChanged( textField.text, textField.text === undefined )
        }
      }
    }
  }

  TextArea {
    id: textArea
    height: config['IsMultiline'] === true ? undefined : 0
    topPadding: customStyle.fields.height * 0.25
    bottomPadding: customStyle.fields.height * 0.25
    leftPadding: customStyle.fields.sideMargin
    rightPadding: textArea.leftPadding + (importDataBtn.visible ? importDataBtn.width : 0)
    visible: height !== 0
    anchors.left: parent.left
    anchors.right: parent.right
    font.pointSize: customStyle.fields.fontPointSize
    wrapMode: Text.Wrap
    color: customStyle.fields.fontColor
    text: value || ''
    textFormat: config['UseHtml'] ? TextEdit.RichText : TextEdit.PlainText

    onLinkActivated: Qt.openUrlExternally(link)

    background: Rectangle {
        color: customStyle.fields.backgroundColor
        radius: customStyle.fields.cornerRadius
    }

    onEditingFinished: {
      if (fieldItem.submitOnEditingFinished) {
        valueChanged( text, text === undefined )
      }
    }

    onTextChanged: {
      if (!fieldItem.submitOnEditingFinished) {
        valueChanged( text, text === undefined )
      }
    }

    }

    // Icon
    Item {
      id: importDataBtn
      visible: supportsDataImport
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.rightMargin: customStyle.fields.sideMargin

      property int borderWidth: 50 * QgsQuick.Utils.dp
      width: fieldItem.iconSize
      height: width
      antialiasing: true

      MouseArea {
        anchors.fill: parent
        onClicked: {
          fieldItem.importDataRequested()
        }
      }

      Image {
        id: importDataBtnIcon
        height: fieldItem.iconSize
        sourceSize.height: fieldItem.iconSize
        autoTransform: true
        fillMode: Image.PreserveAspectFit
        source: customStyle.icons.importData
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: fieldItem.enabled
        anchors.rightMargin: fieldItem.anchors.rightMargin
      }

      ColorOverlay {
        anchors.fill: importDataBtnIcon
        anchors.centerIn: parent
        source: importDataBtnIcon
        color: customStyle.fields.fontColor
        smooth: true
      }
    }
}
