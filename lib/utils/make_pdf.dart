import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:universal_html/html.dart';

class MakePdf{
  double heightHead=80;
  double separationSector=10;
  sector(
      PdfPage page,
      double xIni,
      double xFin,
      double yIni,
      double yFin,
      bool margenInterno,
      List<String> titles1,
      List<String> titles2
      ){
    //margenes
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1.5), Offset(xIni, yIni), Offset(xFin, yIni));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1.5), Offset(xFin, yIni), Offset(xFin, yFin));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1.5), Offset(xFin, yFin), Offset(xIni, yFin));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1.5), Offset(xIni, yFin), Offset(xIni, yIni));
    //margen interno
    if(margenInterno){
      page.graphics.drawLine(
          PdfPen(PdfColor(0, 0, 0), width: .5), Offset(xIni+5, yIni+5), Offset(xFin-5, yIni+5));
      page.graphics.drawLine(
          PdfPen(PdfColor(0, 0, 0), width: .5), Offset(xFin-5, yIni+5), Offset(xFin-5, yFin-5));
      page.graphics.drawLine(
          PdfPen(PdfColor(0, 0, 0), width: .5), Offset(xFin-5, yFin-5), Offset(xIni+5, yFin-5));
      page.graphics.drawLine(
          PdfPen(PdfColor(0, 0, 0), width: .5), Offset(xIni+5, yFin-5), Offset(xIni+5, yIni+5));
    }
    //info
    if(titles1 != null){
      double height = ((yFin-5) - (yIni+5))/titles1.length;
      titles1.forEach((element) {
        int index = titles1.indexOf(element)+1;
        page.graphics.drawLine(
            PdfPen(PdfColor(0, 0, 0), width: .5), Offset(xIni+5, yIni + 5 + (height*index)), Offset(xFin-5, yIni + 5 + (height*index)));
        page.graphics.drawString(
          element,
          PdfStandardFont(PdfFontFamily.timesRoman, 12),
          bounds: Rect.fromLTWH(xIni+10, (yIni + 5 + (height*index))-(height/2)-5, 615, 20),
          format: PdfStringFormat()
        );
      });
    }
    if(titles2 != null){
      double widht = ((xFin-5)-(xIni+5))/2;
      double height = ((yFin-5) - (yIni+5))/titles1.length;
      titles2.forEach((element) {
        int index = titles2.indexOf(element)+1;
        if(element.isNotEmpty){
          page.graphics.drawLine(
              PdfPen(PdfColor(0, 0, 0), width: .5), Offset((xIni)+(widht), yIni + 5 + (height*(index-1))), Offset((xIni)+(widht), yIni + 5 + (height*index)));
          page.graphics.drawString(
            element,
            PdfStandardFont(PdfFontFamily.timesRoman, 12),
            bounds: Rect.fromLTWH((xIni+5)+(widht), (yIni + 5 + (height*index))-(height/2)-5, 615, 20),
          );
        }
      });
    }
  }

  sectorTables(PdfPage page,double w,double h,double xIni,double xFin,double yIni,double yFin, String title,PdfGrid grid){
    //margenes
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1.5), Offset(xIni, yIni), Offset(xFin, yIni));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1.5), Offset(xFin, yIni), Offset(xFin, yFin));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1.5), Offset(xFin, yFin), Offset(xIni, yFin));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1.5), Offset(xIni, yFin), Offset(xIni, yIni));
    //title
    page.graphics.drawString(
      title,
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH(xIni+5, yIni+5, w, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    grid.draw(
        page: page, bounds: Rect.fromLTWH(xIni+5, yIni+20, (xFin)-(xIni), 0));
  }

  sectorObservacion(PdfPage page,double xIni,double xFin,double yIni,double yFin, String title, String text){
    //margenes
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1), Offset(xIni, yIni), Offset(xFin, yIni));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1), Offset(xFin, yIni), Offset(xFin, yFin));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1), Offset(xFin, yFin), Offset(xIni, yFin));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 1), Offset(xIni, yFin), Offset(xIni, yIni));

    //title
    page.graphics.drawString(
      title,
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH(xIni+5, yIni+5, 615, 20),
    );
    page.graphics.drawString(
      text,
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH(xIni+5, yIni+15, 615, 20),
    );
  }

  margin(PdfPage page,double w,double h){
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, 0), Offset(w, 0));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(w, 0), Offset(w, h));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(w, h), Offset(0, h));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, h), Offset(0, 0));
  }

  head(PdfPage page,double w,double h,String titulo)async{
    final ByteData data = await rootBundle.load('assets/images/logo_red.png');
    page.graphics.drawImage(
        PdfBitmap(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)),
        Rect.fromLTWH(10, 20, 120, 40));

    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, heightHead), Offset(w, heightHead));
    double w3 = w / 3;
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset(w3 - 30, 0), Offset(w3 - 30, heightHead));
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, 0), Offset((w3 * 2) + 30, heightHead));

    page.graphics.drawString(
      'Código:',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (heightHead / 4)), Offset(w, (heightHead / 4)));
    page.graphics.drawString(
      'Versión:',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, (heightHead / 4) + 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (heightHead / 4) * 2), Offset(w, (heightHead / 4) * 2));
    page.graphics.drawString(
      'Vigente desde: Jul-2020',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, ((heightHead / 4) * 2) + 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (heightHead / 4) * 3), Offset(w, (heightHead / 4) * 3));
    page.graphics.drawString(
      'Página: 1 de 1',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, ((heightHead / 4) * 3) + 5, 615, 20),
    );

    page.graphics.drawString(
        // 'REGISTRO DE PROCESO \nDE PRODUCCION',
      titulo,
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        bounds: Rect.fromLTWH(w3 , 20, w/3, 60),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );
  }
}