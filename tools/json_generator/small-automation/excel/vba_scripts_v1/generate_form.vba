Sub generate_form()
    
    'Déclaration des variables
    Dim rng          As Range
    Dim row          As Range
    Dim cell         As Range
    Dim mandatory    As Boolean
    Dim question     As String
    Dim categorie    As String
    Dim title        As String
    Dim strID        As String
    Dim strContext   As String
    Dim strCategorie As String
    Dim strName      As String
    Dim strSubObject As String
    Dim strType      As String
    Dim strMandatory As String
    Dim strAuto      As String
    Dim strCmd       As String
    Dim strEnum      As String
    Dim strDefvalue  As String
    Dim strQuestion  As String
    Dim strComment   As String
    Dim numTable     As Integer
    Dim nomObjet     As String
    Dim i            As Integer
    Dim rowNumber    As Integer
    Dim nbTables    As Integer
    Dim tableNames(5) As String
    Dim countTableElements    As Integer
    Dim subTableNbOccurences As New Scripting.Dictionary
    
    Dim formSheet As Worksheet
    Dim sampleInfraSheet As Worksheet
    
    'Initialisation du contexte
    Set sampleInfraSheet = Worksheets("Reference")
    Set formSheet = Worksheets("Formulaire")
    
    Sheets("Formulaire").Activate
    
    rowNumber = 17
    numObject = 0
    numTable = 0
    countTableElements = 0
    nbRequiredValues = 0
    
    'instanciate the number of sub tables we want from the form
    For i = 12 To 14
        strKey = Cells(i, 2).Value
        Position = InStr(1, StrReverse(strKey), ".")
        extractKey = Right(strKey, Position - 1)
        subTableNbOccurences.Add extractKey, Cells(i, 3).Value
    Next i
    
    nbTables = 0
    
    Application.ScreenUpdating = False
    
    'For each row of my sample_infra sheet
    For i = 1 To (Range("DataModelTable").Rows.Count)
        'Get the categorie of the fiels, if is it a basic field we can continue
        strID = Range("DataModelTable").Cells(i, 1).Value
        strContext = Range("DataModelTable").Cells(i, 2).Value
        strCategorie = Range("DataModelTable").Cells(i, 3).Value
        strName = Range("DataModelTable").Cells(i, 4).Value
        strSubObject = Range("DataModelTable").Cells(i, 5).Value
        strType = Range("DataModelTable").Cells(i, 6).Value
        strMandatory = Range("DataModelTable").Cells(i, 7).Value
        strAuto = Range("DataModelTable").Cells(i, 8).Value
        strCmd = Range("DataModelTable").Cells(i, 9).Value
        strEnum = Range("DataModelTable").Cells(i, 10).Value
        strDefvalue = Range("DataModelTable").Cells(i, 11).Value
        strQuestion = Range("DataModelTable").Cells(i, 12).Value
        strComment = Range("DataModelTable").Cells(i, 13).Value
        

        'if the field is mandatory, we can add the question on the form, if the field is an ENUM, we also need to add a validation data list with the potential answers
        If strMandatory = True Then
            mandatory = True
            strMandatory = " CHAMP OBLIGATOIRE "
        Else
            mandatory = False
            strMandatory = " CHAMP FACULTATIF "
        End If
                    
        Select Case strType
            
            Case "Object"
                countTableElements = countTableElements + 1
                If IsInArray(strName, Array("header", "task", "measures", "system", "software", "infrastructure", "environment", "$hash")) Then
                    rowNumber = rowNumber + 2
                    write_title2 formSheet, strName, rowNumber, mandatory
                    'On saute 2 lignes pour aérer
                    numObject = numObject + 1
                    rowNumber = rowNumber + 1
                Else
                    rowNumber = rowNumber + 1
                    write_sub_object formSheet, strName, rowNumber, numTable
                    numObject = numObject + 1
                    nomObjet = strName
                End If
                
            Case "Enum"
                rowNumber = rowNumber + 1
                countTableElements = countTableElements + 1
                write_enum_in_form2 formSheet, strEnum, rowNumber, numTable
                write_question_in_form2 formSheet, strQuestion, strComment, rowNumber, numTable, mandatory
                write_mandatory formSheet, strMandatory, rowNumber, numTable, mandatory
            
            Case "String", "Integer", "Float", "Boolean"
                rowNumber = rowNumber + 1
                countTableElements = countTableElements + 1
                If numTable > 1 Then
                    write_question_in_form2 formSheet, strQuestion, strComment, rowNumber, numTable, mandatory
                Else
                    write_question_in_form2 formSheet, strQuestion, strComment, rowNumber, numTable, mandatory
                End If
                
                write_mandatory formSheet, strMandatory, rowNumber, numTable, mandatory
           
            Case "Table"
                If numTable = 0 Then
                    If IsInArray(strName, Array("header", "task", "measures", "system", "software", "infrastructure", "environment", "$hash")) Then
                        rowNumber = rowNumber + 2
                        write_title2 formSheet, strName, rowNumber, mandatory
                        
                    End If
                    rowNumber = rowNumber + 1
                    write_table_in_form2 formSheet, strQuestion, rowNumber, strComment, mandatory
                    rowNumber = rowNumber + 2
                    numTable = numTable + 1
                    tableNames(numTable) = strName
                    
                'If it is a table nested in another table
                Else
                    'we want to duplicate it the number of times defined in entry by the user, in nbOccurenceTable for example
                    'the str question should give the path of where come this sub table from
                    rowNumber = rowNumber + 1
                    numTable = numTable + 1
                    tableNames(numTable) = strName
                    nbTables = nbTables + 1
                    nbRequiredValues = subTableNbOccurences(strName)

                    write_table_in_form2 formSheet, tableNames(2), rowNumber, strComment, mandatory
                    rowNumber = rowNumber + 3
                    write_table_number formSheet, rowNumber, tableNames(2) + CStr(nbTables)

                    'on met à zéro pour voir cb d'éléments on aura dans le tableau
                    countTableElements = 0
                
                End If
            
            Case "TableEnd"
                
                If numTable = 1 Then
                    rowNumber = rowNumber + 1
                    write_Endtable_in_form2 formSheet, strQuestion, rowNumber, numTable
                    rowNumber = rowNumber + 1
                    numTable = numTable - 1
                    If IsInArray(strName, Array("header End", "task End", "measures End", "system End", "software End", "infrastructure End", "environment End", "$hash End")) Then
                        rowNumber = rowNumber + 1
                        write_title2 formSheet, strName, rowNumber, mandatory
                        rowNumber = rowNumber + 1
                    End If
                    tableNames(1) = ""
                    
                Else
                    If nbTables < nbRequiredValues Then
                        ' -1 pour contrer le next i et ensuite il faut remonter le nombre d'éléments du tableau + le titre
                        i = i - 1 - countTableElements
                        nbTables = nbTables + 1
                        rowNumber = rowNumber + 1
                        write_table_number formSheet, rowNumber, tableNames(2) + CStr(nbTables)
                        countTableElements = 0
                        
                    Else
                        'If it is the end of a list of sub tables
                        rowNumber = rowNumber + 1
                        tableNames(numTable) = ""
                        'si c'est le dernier tableau d'une suite de tableau
                        numTable = numTable - 1
                        nbTables = 0
                    End If
                
                End If
            
            Case "ObjectEnd"
                countTableElements = countTableElements + 1
                If IsInArray(strName, Array("header End", "task End", "measures End", "system End", "software End", "infrastructure End", "environment End", "$hash End")) Then
                    rowNumber = rowNumber + 2
                    write_title2 formSheet, strName, rowNumber, mandatory
                    rowNumber = rowNumber + 1
                End If
                numObject = numObject - 1
                nomObjet = ""
                
        End Select

    Next i
    Range("A1").Select
    Application.ScreenUpdating = True
    
End Sub
Public Function IsInArray(stringToBeFound As String, arr As Variant) As Boolean
    Dim i
    For i = LBound(arr) To UBound(arr)
        If arr(i) = stringToBeFound Then
            IsInArray = True
            Exit Function
        End If
    Next i
    IsInArray = False

End Function

Sub write_title2(formSheet As Worksheet, title As String, row As Integer, mandatory As Boolean)
    If mandatory Then
        mandatoryStar = "*"
    Else
        mandatoryStar = ""
    End If
    formSheet.Cells(row, 2) = title & mandatoryStar
    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Merge
    Cells(row, 2).Font.Bold = False
    Cells(row, 2).HorizontalAlignment = xlCenter
    Cells(row, 2).Font.color = vbPurple
    Cells(row, 2).Font.Size = 16
    Cells(row, 2).VerticalAlignment = xlCenter
    Cells(row, 2).BorderAround ColorIndex:=1, Weight:=xlThick
    Cells(row, 3).BorderAround ColorIndex:=1, Weight:=xlThick
    Cells(row, 4).BorderAround ColorIndex:=1, Weight:=xlThick
    Cells(row, 5).BorderAround ColorIndex:=1, Weight:=xlThick
    Cells(row, 6).BorderAround ColorIndex:=1, Weight:=xlThick
    Cells(row, 7).BorderAround ColorIndex:=1, Weight:=xlThick
    Cells(row, 8).BorderAround ColorIndex:=1, Weight:=xlThick
    Cells(row, 9).BorderAround ColorIndex:=1, Weight:=xlThick
    Rows(row).RowHeight = 20
    
    i = Len(title)
    h = Len(mandatoryStar)

    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Select
    ActiveCell.FormulaR1C1 = title & mandatoryStar
            
            With ActiveCell.Characters(Start:=(i + 1), Length:=(i + h)).Font
                .Name = "Aptos Narrow"
                .Bold = True
                .Size = 8
                .color = vbRed
                .Superscript = False
                .Subscript = False
                .OutlineFont = False
                .Shadow = False
                .Underline = xlUnderlineStyleNone
                .TintAndShade = 0
                .ThemeFont = xlThemeFontMinor
            End With
            
            

End Sub

Sub write_sub_object(formSheet As Worksheet, title As String, row As Integer, numTable As Integer)
    formSheet.Cells(row, 2) = title
    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Merge
    Cells(row, 2).Font.Bold = False
    Cells(row, 2).Font.Name = "Aptos Narrow"
    Cells(row, 2).HorizontalAlignment = xlCenter
    Cells(row, 2).Font.color = vbPurple
    Cells(row, 2).Font.Size = 12
    Cells(row, 2).VerticalAlignment = xlCenter
    Cells(row, 2).BorderAround ColorIndex:=1, Weight:=xlThin
    Cells(row, 3).BorderAround ColorIndex:=1, Weight:=xlThin
    Cells(row, 4).BorderAround ColorIndex:=1, Weight:=xlThin
    Cells(row, 5).BorderAround ColorIndex:=1, Weight:=xlThin
    Cells(row, 6).BorderAround ColorIndex:=1, Weight:=xlThin
    Cells(row, 7).BorderAround ColorIndex:=1, Weight:=xlThin
    Cells(row, 8).BorderAround ColorIndex:=1, Weight:=xlThin
    Cells(row, 9).BorderAround ColorIndex:=1, Weight:=xlThin
    
    If (numTable > 0) Then
        Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Select
        With Selection.Borders(xlEdgeLeft)
            .LineStyle = xlDash
            .ColorIndex = xlAutomatic
            .TintAndShade = 0
            .Weight = xlMedium
        Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Select
        End With
        With Selection.Borders(xlEdgeRight)
            .LineStyle = xlDash
            .ColorIndex = xlAutomatic
            .TintAndShade = 0
            .Weight = xlMedium
        End With
    End If
    
    Rows(row).RowHeight = 20
            
End Sub

Sub write_question_in_form2(formSheet As Worksheet, question As String, strComment As String, row As Integer, numTable As Integer, mandatory As Boolean)

If mandatory Then
    mandatoryStar = "*"
Else
    mandatoryStar = ""
End If

    'if there is no comment, we don't add the "()"
    If strComment = "" Then
    
        Range(formSheet.Cells(row, 2), formSheet.Cells(row, 3)).Merge
        Range(formSheet.Cells(row, 2), formSheet.Cells(row, 3)).Select
        ActiveCell.FormulaR1C1 = question + mandatoryStar
        
        i = Len(question)
        h = Len(mandatoryStar)
        
        With ActiveCell.Characters(Start:=(1), Length:=(i)).Font
                .Name = "Aptos Narrow"
                .Bold = True
                .Size = 8
                .color = vbBlack
                .Superscript = False
                .Subscript = False
                .OutlineFont = False
                .Shadow = False
                .Underline = xlUnderlineStyleNone
                .TintAndShade = 0
                .ThemeFont = xlThemeFontMinor
        End With
            
        With ActiveCell.Characters(Start:=(i + 1), Length:=(i + h)).Font
                .color = vbRed
        End With

        Cells(row, 4).Font.Bold = False
        Cells(row, 4).Font.color = vbBlack
        Cells(row, 4).Font.Size = 8
        Cells(row, 4).HorizontalAlignment = xlLeft
        Cells(row, 4).BorderAround ColorIndex:=1, Weight:=xlThin, LineStyle:=xlDot
        
    Else
        i = Len(question)
        h = Len(mandatoryStar)
        j = Len(question & mandatoryStar & " (" + strComment + ")")
        formSheet.Cells(row, 2) = question & mandatoryStar & " (" & strComment & ")"
        
        Range(formSheet.Cells(row, 2), formSheet.Cells(row, 3)).Merge
        
        Range(formSheet.Cells(row, 2), formSheet.Cells(row, 3)).Select
        ActiveCell.FormulaR1C1 = question & mandatoryStar & " (" & strComment & ")"
    
        With ActiveCell.Characters(Start:=(1), Length:=(i)).Font
                .Name = "Aptos Narrow"
                .Bold = True
                .Size = 8
                .color = vbBlack
                .Superscript = False
                .Subscript = False
                .OutlineFont = False
                .Shadow = False
                .Underline = xlUnderlineStyleNone
                .TintAndShade = 0
                .ThemeFont = xlThemeFontMinor
            End With
            
            With ActiveCell.Characters(Start:=(i + 1), Length:=(i + h)).Font
                .Name = "Aptos Narrow"
                .Bold = True
                .Size = 8
                .color = vbRed
                .Superscript = False
                .Subscript = False
                .OutlineFont = False
                .Shadow = False
                .Underline = xlUnderlineStyleNone
                .TintAndShade = 0
                .ThemeFont = xlThemeFontMinor
            End With
            
            With ActiveCell.Characters(Start:=(i + h + 1), Length:=(j)).Font
                .Name = "Aptos Narrow"
                .FontStyle = "Normal"
                .Size = 6
                .Strikethrough = False
                .Superscript = False
                .Subscript = False
                .OutlineFont = False
                .Shadow = False
                .Underline = xlUnderlineStyleNone
                .color = vbBlack
                .TintAndShade = 0
                .ThemeFont = xlThemeFontMinor
            End With
        Cells(row, 4).Font.Bold = False
        Cells(row, 4).Font.color = vbBlack
        Cells(row, 4).Font.Size = 8
        Cells(row, 4).HorizontalAlignment = xlLeft
        Cells(row, 4).BorderAround ColorIndex:=1, Weight:=xlThin, LineStyle:=xlDot
        RowHeight = Round(i / 50, 1) + 1
        
        Rows(row).RowHeight = 20 * RowHeight
    End If
    
    If numTable > 0 Then
        Range(Cells(row, 4), Cells(row, 9)).Font.Bold = False
        Range(Cells(row, 4), Cells(row, 9)).Font.color = vbBlack
        Range(Cells(row, 4), Cells(row, 9)).Font.Size = 8
        Range(Cells(row, 4), Cells(row, 9)).HorizontalAlignment = xlCenter
    
        'draw the table separating lines
        Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Select
        With Selection.Borders(xlEdgeLeft)
            .LineStyle = xlDash
            .ColorIndex = xlAutomatic
            .TintAndShade = 0
            .Weight = xlMedium
        End With
        With Selection.Borders(xlEdgeTop)
            .LineStyle = xlContinuous
            .ColorIndex = xlAutomatic
            .TintAndShade = 0
            .Weight = xlThin
        End With
        With Selection.Borders(xlEdgeBottom)
            .LineStyle = xlContinuous
            .ColorIndex = xlAutomatic
            .TintAndShade = 0
            .Weight = xlThin
        End With
        With Selection.Borders(xlEdgeRight)
            .LineStyle = xlDash
            .ColorIndex = xlAutomatic
            .TintAndShade = 0
            .Weight = xlMedium
        End With
        With Selection.Borders(xlInsideVertical)
            .LineStyle = xlContinuous
            .ColorIndex = xlAutomatic
            .TintAndShade = 0
            .Weight = xlThin
        End With
        With Selection.Borders(xlInsideHorizontal)
            .LineStyle = xlContinuous
            .ColorIndex = xlAutomatic
            .TintAndShade = 0
            .Weight = xlThin
        End With
    End If
 
End Sub

Sub write_enum_in_form2(formSheet As Worksheet, strEnum As String, row As Integer, numTable As Integer)
       
    Cells(row, 4).Font.Bold = True
    Cells(row, 4).HorizontalAlignment = xlCenter
    Cells(row, 4).Font.color = vbBlack
    Cells(row, 4).Font.Size = 8
    Cells(row, 4).Validation.Delete
    Cells(row, 4).Validation.Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:=xlBetween, Formula1:=strEnum
    Cells(row, 4).BorderAround ColorIndex:=1, Weight:=xlThin, LineStyle:=xlDot
    
 
End Sub
Sub write_table_in_form2(formSheet As Worksheet, tableName As String, row As Integer, comment As String, mandatory As Boolean)

    If mandatory Then
    mandatoryStar = "*"
    Else
        mandatoryStar = ""
    End If
    
    i = Len(tableName)
    h = Len(mandatoryStar)
    
    formSheet.Cells(row + 1, 3) = tableName + mandatoryStar
    Range(formSheet.Cells(row + 1, 3), formSheet.Cells(row + 1, 3)).Select
    
    ActiveCell.FormulaR1C1 = tableName + mandatoryStar
    
    With ActiveCell.Characters(Start:=(1), Length:=(i)).Font
                .Name = "Aptos Narrow"
                .Bold = True
                .Size = 8
                .color = vbBlack
            End With
        
    With ActiveCell.Characters(Start:=(i + 1), Length:=(i + h)).Font
        .color = vbRed
    End With
    

    formSheet.Cells(row + 2, 4) = "N°1"
    formSheet.Cells(row + 2, 5) = "N°2"
    formSheet.Cells(row + 2, 6) = "N°3"
    formSheet.Cells(row + 2, 7) = "N°4"
    formSheet.Cells(row + 2, 8) = "N°5"
    formSheet.Cells(row + 2, 9) = "..."
    Range(formSheet.Cells(row + 1, 4), formSheet.Cells(row + 1, 9)).Merge
    formSheet.Cells(row + 1, 4) = comment
    Cells(row + 1, 4).Font.color = vbOrange
    Cells(row + 1, 4).Font.Size = 8
    Cells(row + 1, 4).HorizontalAlignment = xlCenter
    
    Range(formSheet.Cells(row + 1, 2), formSheet.Cells(row + 2, 9)).Select
        Selection.Borders(xlDiagonalDown).LineStyle = xlNone
    Selection.Borders(xlDiagonalUp).LineStyle = xlNone
    With Selection.Borders(xlEdgeLeft)
        .LineStyle = xlDash
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Weight = xlMedium
    End With
    Selection.Borders(xlEdgeBottom).LineStyle = xlNone
    With Selection.Borders(xlEdgeTop)
        .LineStyle = xlDash
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Weight = xlMedium
    End With
    With Selection.Borders(xlEdgeRight)
        .LineStyle = xlDash
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Weight = xlMedium
    End With
    Selection.Borders(xlInsideVertical).LineStyle = xlNone
    Selection.Borders(xlInsideHorizontal).LineStyle = xlNone

    Range(formSheet.Cells(row + 2, 4), formSheet.Cells(row + 2, 9)).Select
    With Selection.Font
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Name = "Aptos Narrow"
        .Size = 9
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .ThemeFont = xlThemeFontMinor
    End With
    With Selection
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlBottom
        .WrapText = True
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
        .MergeCells = False
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .WrapText = True
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
        .MergeCells = False
    End With
    Selection.Borders(xlDiagonalDown).LineStyle = xlNone
    Selection.Borders(xlDiagonalUp).LineStyle = xlNone
    With Selection.Borders(xlEdgeLeft)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With Selection.Borders(xlEdgeTop)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With Selection.Borders(xlEdgeBottom)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With Selection.Borders(xlEdgeRight)
        .LineStyle = xlDash
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlMedium
    End With
    With Selection.Borders(xlInsideVertical)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With Selection.Borders(xlInsideHorizontal)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With

    Range(formSheet.Cells(row + 1, 2), formSheet.Cells(row + 2, 3)).Select
    With Selection
        .HorizontalAlignment = xlCenter
        .WrapText = True
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
        .MergeCells = False
    End With
    Selection.Merge
    With Selection
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .WrapText = True
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
        .MergeCells = True
    End With
    With Selection.Font
        .Name = "Aptos Narrow"
        .Size = 12
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .TintAndShade = 0
        .ThemeFont = xlThemeFontMinor
    End With

End Sub

Sub write_mandatory(formSheet As Worksheet, strMandatory As String, row As Integer, numTable As Integer, mandatory As Boolean)
    
Dim color As String
If mandatory Then
    color = vbRed
Else
    color = vbBlue
End If
    
    If (numTable = 0) Then
        formSheet.Cells(row, 6) = strMandatory
        Range(formSheet.Cells(row, 6), formSheet.Cells(row, 8)).Merge
        Cells(row, 6).Font.Bold = False
        Cells(row, 6).HorizontalAlignment = xlCenter
        Cells(row, 6).Font.color = color
        Cells(row, 6).Font.Size = 8
        
   End If
    
    
End Sub


Sub write_Endtable_in_form2(formSheet As Worksheet, title As String, row As Integer, numTable As Integer)

    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Select
    Selection.Borders(xlDiagonalDown).LineStyle = xlNone
    Selection.Borders(xlDiagonalUp).LineStyle = xlNone
    With Selection.Borders(xlEdgeLeft)
        .LineStyle = xlDash
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Weight = xlMedium
    End With
    Selection.Borders(xlEdgeTop).LineStyle = xlNone
    With Selection.Borders(xlEdgeBottom)
        .LineStyle = xlDash
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Weight = xlMedium
    End With
    With Selection.Borders(xlEdgeRight)
        .LineStyle = xlDash
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Weight = xlMedium
    End With
    With Selection.Borders(xlEdgeTop)
        .LineStyle = xlContinuous
        .ColorIndex = xlAutomatic
        .TintAndShade = 0.249946592608417
        .Weight = xlThin
    End With
    Selection.Borders(xlInsideVertical).LineStyle = xlNone
    Selection.Borders(xlInsideHorizontal).LineStyle = xlNone

End Sub

Sub write_table_number(formSheet As Worksheet, row As Integer, tableName As String)
    formSheet.Cells(row, 4) = tableName
    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Select
    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Merge
    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).HorizontalAlignment = xlCenter
    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Font.Name = "Aptos Narrow"
    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Font.color = vbBlack
    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Font.Size = 11
    Range(formSheet.Cells(row, 2), formSheet.Cells(row, 9)).Font.Bold = True
    With Selection.Borders(xlEdgeLeft)
        .LineStyle = xlDash
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Weight = xlMedium
    End With
    With Selection.Borders(xlEdgeTop)
        .LineStyle = xlContinuous
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With Selection.Borders(xlEdgeBottom)
        .LineStyle = xlContinuous
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With Selection.Borders(xlEdgeRight)
        .LineStyle = xlDash
        .ColorIndex = xlAutomatic
        .TintAndShade = 0
        .Weight = xlMedium
    End With
    
End Sub
    
