
import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/models/model_reserva_itmes_proc_prod.dart';
import 'package:andeanvalleysystem/models/model_salidas_bajas.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/utils/make_pdf.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';

class PrintPDF{
  static impresionIngresos(
      String nombre,
      ModelAlmacenes selectionAlmacen,
      String ecFecIngreso,
      List<ModelInventario>inventarioSelected
      )async{
    PdfDocument document = PdfDocument();
    PdfPage page = document.pages.add();
    double w = document.pages[0].getClientSize().width;
    double h = document.pages[0].getClientSize().height;
    document.pageSettings.margins.all = 20;
    final ByteData data = await rootBundle.load('assets/images/logo_red.png');
    page.graphics.drawImage(
        PdfBitmap(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)),
        Rect.fromLTWH(20, 20, 120, 40));

    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, 80), Offset(w, 80));
    double w3 = w / 3;
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset(w3 - 30, 0), Offset(w3 - 30, 80));
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, 0), Offset((w3 * 2) + 30, 80));

    page.graphics.drawString(
      'Código:',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (80 / 4)), Offset(w, (80 / 4)));
    page.graphics.drawString(
      'Versión:',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, (80 / 4) + 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (80 / 4) * 2), Offset(w, (80 / 4) * 2));
    page.graphics.drawString(
      'Vigente desde: Jul-2020',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, ((80 / 4) * 2) + 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (80 / 4) * 3), Offset(w, (80 / 4) * 3));
    page.graphics.drawString(
      'Página: 1 de 1',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, ((80 / 4) * 3) + 5, 615, 20),
    );

    page.graphics.drawString(
      'COMPROBANTE DE INGRESO',
      PdfStandardFont(PdfFontFamily.timesRoman, 15),
      bounds: Rect.fromLTWH(w3 - 15, 40, 615, 20),
    );

    page.graphics.drawString(
        'CODIGO:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 100, 200, 20));
    page.graphics.drawString(
        nombre, PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 100, 200, 20));
    page.graphics.drawString(
        'ALMACEN:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 120, 200, 20));
    page.graphics.drawString(
        '${selectionAlmacen.codAlm} - ${selectionAlmacen.name}',
        PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 120, 200, 20));
    page.graphics.drawString(
        'GENERADO POR:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 140, 200, 20));
    page.graphics.drawString(
        'VICTOR MAMANI', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 140, 200, 20));
    page.graphics.drawString(
        'FECHA DE LLEGADA:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 160, 200, 20));
    page.graphics.drawString(
        '${ecFecIngreso}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 160, 200, 20));
    page.graphics.drawString(
        'FECHA DE REGISTRO:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 180, 200, 20));
    page.graphics.drawString(
        DateFormat("dd/MM/yyyy").format(DateTime.now()) , PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 180, 200, 20));

    page.graphics.drawString(
        'Firma Responsable de ingreso ________________________________',
        PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(w - 450, h - 60, 600, 20));

    PdfGrid grid = PdfGrid();

//Add the columns to the grid
    grid.columns.add(count: 9);

//Add header to the grid
    grid.headers.add(1);

//Add the rows to the grid
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Codigo';
    header.cells[1].value = 'Descripcion';
    header.cells[2].value = 'Unid.';
    header.cells[3].value = 'Cantidad';
    header.cells[4].value = 'Costo Unitario [Bs/u]';
    header.cells[5].value = 'Lote';
    header.cells[6].value = 'Proveedor';
    header.cells[7].value = 'Venc.';
    header.cells[8].value = 'Nº Factura';
    header.style = PdfGridRowStyle(
      backgroundBrush: PdfBrushes.cornflowerBlue,
      textBrush: PdfBrushes.white,
    );

    header.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
    );
    header.cells[1].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[2].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[3].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[4].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[5].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[6].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[7].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[8].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);

    inventarioSelected.forEach((element) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = '${element.codProd}';
      row.cells[1].value = '${element.producto.nombre}';
      row.cells[2].value = '${element.producto.titulo}';
      row.cells[3].value = '${NumberFunctions.formatNumber(element.cantidad, 2)}';
      row.cells[4].value = '${NumberFunctions.formatNumber(element.costoUnitario,2)}';
      row.cells[5].value = '${element.lote}';
      row.cells[6].value = '${element.proveedor.nombre}';
      row.cells[7].value = '${element.fecVencimiento}';
      row.cells[8].value = '${element.factura}';

      row.cells[0].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[2].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[3].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[4].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[5].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[7].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[8].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);

      if (inventarioSelected.indexOf(element) % 2 == 0) {
        row.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.aliceBlue);
      } else {
        row.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.white);
      }
    });
    grid.columns[1].width = 120;
    grid.columns[6].width = 100;

    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 1),
        backgroundBrush: PdfBrushes.aliceBlue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 10),
        borderOverlapStyle: PdfBorderOverlapStyle.inside);

    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 220, 0, 0));

    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, 0), Offset(w, 0));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(w, 0), Offset(w, h));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(w, h), Offset(0, h));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, h), Offset(0, 0));

    List<int> bytes = document.save();
    document.dispose();

    js.context['pdfData'] = base64.encode(bytes);
    js.context['filename'] = '$nombre.pdf';
    Timer.run(() async{
      js.context.callMethod('download');
    });
  }

  static impresionTransferencias()async{

  }

  static impresionProcesoProduccion(
      String nombre,
      String loteProd,
      double costoTotalReceta,
      double costoTotalReal,
      double variacion,
      ModelProcesoProduccion procProd,
      List<ModelReservaItemsProcProd> ingredientesIn,
      List<ModelReservaItemsProcProd> ingredientesOut
      )async{
    PdfDocument document = PdfDocument();
    PdfPage page = document.pages.add();
    double w = document.pages[0].getClientSize().width;
    double h = document.pages[0].getClientSize().height;
    document.pageSettings.margins.all = 20;
    final ByteData data = await rootBundle.load('assets/images/logo_red.png');
    page.graphics.drawImage(
        PdfBitmap(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)),
        Rect.fromLTWH(10, 20, 120, 40));

    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, 80), Offset(w, 80));
    double w3 = w / 3;
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset(w3 - 30, 0), Offset(w3 - 30, 80));
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, 0), Offset((w3 * 2) + 30, 80));

    page.graphics.drawString(
      'Código:',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (80 / 4)), Offset(w, (80 / 4)));
    page.graphics.drawString(
      'Versión:',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, (80 / 4) + 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (80 / 4) * 2), Offset(w, (80 / 4) * 2));
    page.graphics.drawString(
      'Vigente desde: Jul-2020',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, ((80 / 4) * 2) + 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (80 / 4) * 3), Offset(w, (80 / 4) * 3));
    page.graphics.drawString(
      'Página: 1 de 1',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, ((80 / 4) * 3) + 5, 615, 20),
    );

    page.graphics.drawString(
        'REGISTRO DE PROCESO \nDE PRODUCCION',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        bounds: Rect.fromLTWH(w3 , 20, w/3, 60),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    // page.graphics.drawString(
    //     'PROCESO ENVIADO A APROBACIÓN \nEN ${DateFormat("dd/MM/yyyy").format(DateTime.now())}',
    //     PdfStandardFont(PdfFontFamily.timesRoman, 20),
    //     bounds: Rect.fromLTWH(30, 100, w, 50),
    //     format: PdfStringFormat(alignment: PdfTextAlignment.center),
    //   brush: PdfSolidBrush(PdfColor(255, 25, 25,1))
    // );

    page.graphics.drawString(
        'ID:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 100, 200, 20));
    page.graphics.drawString(
        "${procProd.id}", PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 100, 200, 20));
    page.graphics.drawString(
        'ALMACEN:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 120, 200, 20));
    page.graphics.drawString(
        '${procProd.codAlmProd} - ALMACEN DE PRODUCTO EN PROCESO BENEFICIADO',
        PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 120, 300, 20));
    page.graphics.drawString(
        'GENERADO POR:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 140, 200, 20));
    page.graphics.drawString(
        'USUARIO', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 140, 200, 20));
    page.graphics.drawString(
        'FECHA DE REGISTRO:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 160, 200, 20));
    page.graphics.drawString(
        '${DateFormat("dd/MM/yyyy").format(DateTime.now())}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 160, 200, 20));
    page.graphics.drawString(
        'LOTE DE PRODUCCION:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 180, 200, 20));
    page.graphics.drawString(
        '${procProd.loteProd}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 180, 200, 20));

    page.graphics.drawString(
        'Firma Responsable ________________________________',
        PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(w - 450, h - 60, 600, 20));

    PdfGrid inGrid = PdfGrid();
    inGrid.columns.add(count: 7);
    inGrid.headers.add(1);
    PdfGridRow inHeader = inGrid.headers[0];
    inHeader.cells[0].value = 'Codigo';
    inHeader.cells[1].value = 'Descripcion';
    inHeader.cells[2].value = 'Unid.';
    inHeader.cells[3].value = 'Cantidad Real';
    inHeader.cells[4].value = 'Costo Unitario [Bs/u]';
    inHeader.cells[5].value = 'Costo Total Real [Bs]';
    inHeader.cells[6].value = 'Lote Producto';
    inHeader.style = PdfGridRowStyle(
      backgroundBrush: PdfBrushes.cornflowerBlue,
      textBrush: PdfBrushes.white,
    );
    inHeader.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
    );
    inHeader.cells[1].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    inHeader.cells[2].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    inHeader.cells[3].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    inHeader.cells[4].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    inHeader.cells[5].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    inHeader.cells[6].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);

    page.graphics.drawString(
        'INGREDIENTES',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        bounds: Rect.fromLTWH(w3 , 200, w/3, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    ingredientesIn.forEach((element) {
      print("${element.codProd}::${element.nombreProd}::${element.unidad}::${element.cantidad}::${element.costoUnit}::${(element.cantidad*element.costoUnit)}");
      PdfGridRow inRow = inGrid.rows.add();
      inRow.cells[0].value = '${element.codProd}';
      inRow.cells[1].value = '${element.nombreProd}';
      inRow.cells[2].value = '${element.unidad}';
      inRow.cells[3].value = '${element.cantidad}';
      inRow.cells[4].value = "${NumberFunctions.formatNumber(element.costoUnit,3)}";
      inRow.cells[5].value = "${NumberFunctions.formatNumber(element.cantidad*element.costoUnit,3)}";
      inRow.cells[6].value = "${element.lote}";

      inRow.cells[0].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      inRow.cells[2].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      inRow.cells[3].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      inRow.cells[4].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      inRow.cells[5].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      if (procProd.reservas.indexOf(element) % 2 == 0) {
        inRow.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.aliceBlue);
      } else {
        inRow.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.white);
      }
    });

    inGrid.columns[1].width = 120;
    inGrid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 1),
        backgroundBrush: PdfBrushes.aliceBlue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 10),
        borderOverlapStyle: PdfBorderOverlapStyle.inside);
    inGrid.draw(page: page, bounds: const Rect.fromLTWH(0, 220, 0, 0));

    PdfGrid outGrid = PdfGrid();
    outGrid.columns.add(count: 7);
    outGrid.headers.add(1);
    PdfGridRow outHeader = outGrid.headers[0];
    outHeader.cells[0].value = 'Codigo';
    outHeader.cells[1].value = 'Descripcion';
    outHeader.cells[2].value = 'Unid.';
    outHeader.cells[3].value = 'Cantidad Real';
    outHeader.cells[4].value = 'Costo Unitario [Bs/u]';
    outHeader.cells[5].value = 'Costo Total Real [Bs]';
    outHeader.cells[6].value = 'Lote Producto';
    outHeader.style = PdfGridRowStyle(
      backgroundBrush: PdfBrushes.cornflowerBlue,
      textBrush: PdfBrushes.white,
    );
    outHeader.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
    );
    outHeader.cells[1].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    outHeader.cells[2].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    outHeader.cells[3].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    outHeader.cells[4].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    outHeader.cells[5].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    outHeader.cells[6].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);

    double dis = (220+(ingredientesIn.length.toDouble()*50)+50);
    page.graphics.drawString(
        'RESULTADO',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        bounds: Rect.fromLTWH(w3 , dis-20, w/3, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    ingredientesOut.forEach((salidas) {
      PdfGridRow outRow = outGrid.rows.add();
      outRow.cells[0].value = '${salidas.codProd}';
      outRow.cells[1].value = '${salidas.nombreProd}';
      outRow.cells[2].value = '${salidas.unidad}';
      outRow.cells[3].value = '${NumberFunctions.formatNumber(salidas.cantidad,2)}';
      outRow.cells[4].value = "${NumberFunctions.formatNumber(salidas.costoUnit,3)}";
      outRow.cells[5].value = "${NumberFunctions.formatNumber(salidas.cantidad*salidas.costoUnit,3)}";
      outRow.cells[6].value = loteProd;
      outRow.cells[0].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      outRow.cells[2].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      outRow.cells[3].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      outRow.cells[4].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      outRow.cells[5].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      if (procProd.reservas.indexOf(salidas) % 2 == 0) {
        outRow.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.aliceBlue);
      } else {
        outRow.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.white);
      }
    });

    outGrid.columns[1].width = 120;
    outGrid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 1),
        backgroundBrush: PdfBrushes.aliceBlue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 10),
        borderOverlapStyle: PdfBorderOverlapStyle.inside);
    outGrid.draw(page: page, bounds: Rect.fromLTWH(0, dis, 0, 0));

    page.graphics.drawString(
        'COSTO TOTAL RECETA: ${NumberFunctions.formatNumber(costoTotalReceta,3)}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(5, dis+(ingredientesOut.length*35)+60, w, 20));
    page.graphics.drawString(
        'COSTO TOTAL REAL: ${NumberFunctions.formatNumber(costoTotalReal,3)}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(5, dis+(ingredientesOut.length*35)+80, w, 20));
    page.graphics.drawString(
        'VARIACION: ${variacion.toStringAsFixed(2)}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(5, dis+(ingredientesOut.length*35)+100, w, 20));


    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, 0), Offset(w, 0));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(w, 0), Offset(w, h));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(w, h), Offset(0, h));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, h), Offset(0, 0));

    if(variacion<-3 || variacion>3){
      PdfGraphics graphics = page.graphics;
      PdfGraphicsState state = graphics.save();
      graphics.setTransparency(0.25);
      graphics.rotateTransform(-40);
      graphics.drawString('PROCESO ENVIADO A APROBACIÓN \nEN ${DateFormat("dd/MM/yyyy").format(DateTime.now())}',
          PdfStandardFont(PdfFontFamily.helvetica, 30),
          format: PdfStringFormat(alignment: PdfTextAlignment.center),
          pen: PdfPens.red,
          brush: PdfBrushes.red,
          bounds: Rect.fromLTWH(-w+480, (h/2)+50, 0, 0));
      graphics.restore(state);
    }

    List<int> bytes = document.save();
    document.dispose();

    js.context['pdfData'] = base64.encode(bytes);
    js.context['filename'] = '$nombre.pdf';
    Timer.run(() {
      js.context.callMethod('download');
    });
  }

  static impresionSalidaBaja(
      String nombreDoc,
      double cantidadTotal,
      double costoTotal,
      ModelSalidasBajas i,
      List<ModelSalidasBajas> items
      )async{
    PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 10;
    PdfPage page = document.pages.add();

    double w = document.pages[0].getClientSize().width;
    double h = document.pages[0].getClientSize().height;
    print("$w::$h");

    MakePdf().margin(page, w, h);
    await MakePdf().head(page, w, h,'REGISTRO DE ${i.tipo}');
    List<String> title = [
      "Código:\t${i.codigoSalida}",
      "Tipo:\t${i.tipo}",
      "Almacen:\t${i.codAlm}-${i.nameAlmacen}",
      "Motivo:\t${i.motivo}",
      "Registro:\t${i.fecReg}",
      "Solicitante:\t${i.usuario}",
      "Area Destino:\t${i.area}"
    ];
    List<String> titles2 = [
      "Fecha:\t${DateFormat("dd/MM/yyyy").format(DateTime.now())}",
      "","","","","",""];

    MakePdf().sector(page, 5, w-5,90,215,true,title,titles2);
    List<String> titleTotal = [
      "Cantidad Total del egreso:\t${NumberFunctions.formatNumber(cantidadTotal, 2)}.",
      "Valor Total del egreso:\t${NumberFunctions.formatNumber(costoTotal, 3)} Bolivianos.",
      "Observaciones:\t${i.observacion}"
    ];
    List<String> titles2Total = [
      "",
      "","","","","",""];
    MakePdf().sector(page, 5, w-5,h-145,h-90,true,titleTotal,titles2Total);
    double heightRes = (((h-90)-(310))/2)-10;

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 8);
    grid.headers.add(1);
    grid.columns[1].width = 200;
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'CODIGO';
    header.cells[1].value = 'PRODUCTO';
    header.cells[2].value = 'UNIDAD';
    header.cells[3].value = 'CANTIDAD';
    header.cells[4].value = 'LOTE';
    header.cells[5].value = 'FECHA VENCIMIENTO';
    header.cells[6].value = 'COSTO UNITARIO Bs.';
    header.cells[7].value = 'COSTO TOTAL Bs.';

    header.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[1].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,

    );
    header.cells[2].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[3].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[4].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[5].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[6].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[7].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );

    items.forEach((element) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = element.codigoSalida;
      row.cells[1].value = element.nombreProd;
      row.cells[2].value = element.unidadMedida;
      row.cells[3].value = "${element.cantidad}";
      row.cells[4].value = "${element.lote}";
      row.cells[5].value = "${element.fecVencimiento}";
      row.cells[6].value = "${NumberFunctions.formatNumber(element.costoUnit,4)}";
      row.cells[7].value = "${NumberFunctions.formatNumber(element.cantidad*element.costoUnit,4)}";
      grid.rows[items.indexOf(element)].height = 23;
    });

    // itemsSeleccionados.forEach((element) {
    //   PdfGridRow row = grid.rows.add();
    //   row.cells[0].value = element.codigo;
    //   row.cells[1].value = element.nombre;
    //   row.cells[2].value = element.titulo;
    //   row.cells[3].value = "${inventorySelect[itemsSeleccionados.indexOf(element)].cantidadTotalLotes}";
    //   row.cells[4].value = "${
    //     inventorySelect[itemsSeleccionados.indexOf(element)]
    //         .lotes
    //         .map((e) => "${e.lote}|")
    //         .toList()
    //   }";
    //   grid.rows[itemsSeleccionados.indexOf(element)].height = 23;
    // });

    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
        // backgroundBrush: PdfBrushes.blue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 8)
    );
    MakePdf().sectorTables(page, w, h, 5, w-5,220,h-150,"ITEMS Y CANTIDADES PARA LA ${i.tipo}",grid);


    MakePdf().sectorObservacion(page, 5, w/2,h-85,h-5,"Solicitado por:","");
    MakePdf().sectorObservacion(page, w/2, w-5,h-85,h-5,"Realizado por:","");

    List<int> bytes = document.save();
    document.dispose();

    js.context['pdfData'] = base64.encode(bytes);
    js.context['filename'] = '$nombreDoc.pdf';
    Timer.run(() {
      js.context.callMethod('download');
    });
  }
}