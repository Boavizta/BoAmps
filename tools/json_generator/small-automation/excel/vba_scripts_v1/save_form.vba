Sub save_form()
    
    'Déclaration des variables
    Dim rng          As Range
    Dim row          As Range
    Dim cell         As Range
    Dim mandatory    As Boolean
    Dim res          As Boolean
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
    Dim i            As Integer
    Dim nbSubComponents As Integer
    Dim rowNumber    As Integer
    Dim rowsave      As Integer
    Dim colNumber    As Integer
    
    Dim formSheet As Worksheet
    Dim sampleInfraSheet As Worksheet
    Dim startTable(5) As String
    Dim rowNumBegin(5) As String
    Dim rowNumEnd(5) As String
    Dim nbSubOccurences As Integer
    Dim subTableNbOccurences As New Scripting.Dictionary
    
    'to store the information about main tables : algorithms & dataset
    'TableProperties[0] : number of the starting row of the table in the form
    'TableProperties[1] : number of the starting row of the table in the datamodel
    'TableProperties[2] : number of items in the tab (excepting the sub tables items)
    Dim TableProperties(2)
    
    'to store the information about the subTable
    'SubTableProperties[0] : number of the starting row in the form
    'SubTableProperties[1] : number of the end row of in the form
    'SubTableProperties[2] : number of the strating row of in the datamodel
    'SubTableProperties[3] : number of the starting row in the block of tables in the form
    'SubTableProperties[4] : number of the ending row in the block of tables in the form
    'SubTableProperties[5] : total number of occurences of the table in the form
    'SubTableProperties[6] : number of occurences of the table which have already been read
    Dim SubTableProperties(6)
    
    'to store the information about the previous subTable
    'previousSubTable[0] : number of the starting row of the block in the form
    'previousSubTable[1] : number of the end row of of the block in the form
    Dim previousSubTable(2)
    
    'Initialisation du contexte
    Set sampleInfraSheet = Worksheets("Reference")
    Set formSheet = Worksheets("Formulaire")
    
    Sheets("Formulaire").Activate
    
    rowNumber = 17
    numObject = 0
    numTable = 0
    res = False
    firstline = True
    previousSubTable(0) = 0
    previousSubTable(1) = 0
    
    Sheets("Formulaire").Activate
    'instanciate the number of sub tables we want from the form
    For i = 12 To 14
        strKey = Cells(i, 2).Value
        Position = InStr(1, StrReverse(strKey), ".")
        extractKey = Right(strKey, Position - 1)
        subTableNbOccurences.Add extractKey, Cells(i, 3).Value
    Next i
    
    
    Application.ScreenUpdating = False
    
    strSaveName = Range("C9").Value
    strRestoName = Range("C8").Value
    
    colNumber = 4
    
    
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
        
                    
        Select Case strType
            
            Case "Object"
                result = ""
                numObject = numObject + 1
                If IsInArray(strName, Array("header", "task", "measures", "system", "software", "infrastructure", "environment", "$hash")) Then
                    rowNumber = rowNumber + 3
                Else
                    rowNumber = rowNumber + 1
                End If
                
            Case "Enum", "String", "Integer", "Float", "Boolean"
                rowNumber = rowNumber + 1
                result = read_result_in_form2(formSheet, rowNumber, colNumber)
                res = True
            
            Case "Table"
                result = ""
                numTable = numTable + 1
                tableName = strName
                'si c'est le début d'un tableau général
                If (numTable = 1) Then
                    If IsInArray(strName, Array("header", "task", "measures", "system", "software", "infrastructure", "environment", "$hash")) Then
                        rowNumber = rowNumber + 2
                    End If
                    rowNumber = rowNumber + 3
                    TableProperties(0) = rowNumber + 1
                    TableProperties(1) = i
                    SubTableProperties(0) = 0
                Else
                    'if it is the first table of sub table list
                    If SubTableProperties(0) = 0 Then
                        rowNumber = rowNumber + 4
                    'if it not the first alements of a subtable
                    Else
                        rowNumber = SubTableProperties(1) + 1
                    End If
                    SubTableProperties(0) = rowNumber + 1
                    SubTableProperties(3) = rowNumber + 1
                    SubTableProperties(2) = i
                    SubTableProperties(5) = subTableNbOccurences(strName)
                    SubTableProperties(6) = SubTableProperties(6) + 1
                End If
                           
            
            Case "TableEnd"

                result = ""
                
                'Si c'est la fin d'un tableau principal, il faut regarder la colonne suivante pour vérifier s'il y a des colonnes à rajouter
                If numTable = 1 Then
                    isItEmpty = ""
                    'S'il y a des sous tableaux dans ce tableau
                    If (SubTableProperties(3) <> 0) Then
                        'du début du tableau à la ligne courante on check s'il y a des valeurs
                        For j = TableProperties(0) To rowNumber
                            'to avoid the first subtable of the big table(shape)
                            If j >= previousSubTable(0) - 3 And j <= previousSubTable(1) Then
                                isItEmpty = isItEmpty
                            'en évitant les lignes des sous tableaux
                            'il y a 3 lignes avant la première valeur d'un sous tableau
                            ElseIf j >= SubTableProperties(3) - 3 And j <= SubTableProperties(4) Then
                                isItEmpty = isItEmpty
                            'si c'est une cellule mergée alors on n'ajoute pas la valeur
                            ElseIf formSheet.Cells(j, 2).Value = formSheet.Cells(j, 4).Value Then
                                isItEmpty = isItEmpty
                            Else
                                isItEmpty = isItEmpty + CStr(formSheet.Cells(j, colNumber + 1).Value)
                            End If
                        Next j
                    'Si c'est un tableau sans sous tableau
                    Else
                        For j = TableProperties(0) To rowNumber
                                If (formSheet.Cells(j, colNumber + 1).Value = formSheet.Cells(j, 4).Value) Then
                                    isItEmpty = isItEmpty
                                Else
                                    isItEmpty = isItEmpty + CStr(formSheet.Cells(j, colNumber + 1).Value)
                                End If
                            Next j
                    End If
                    'End of a global table
                    If isItEmpty = "" Then
                            'tout réinitialiser
                            SubTableProperties(0) = 0
                            SubTableProperties(1) = 0
                            SubTableProperties(2) = 0
                            SubTableProperties(3) = 0
                            SubTableProperties(4) = 0
                            SubTableProperties(5) = 0
                            SubTableProperties(6) = 0
                            TableProperties(0) = 0
                            TableProperties(1) = 0
                            TableProperties(2) = 0
                            previousSubTable(0) = 0
                            previousSubTable(1) = 0
                            rowNumber = rowNumber + 2
                            numTable = numTable - 1
                            colNumber = 4
                            strType = "TableEnd"
                            If IsInArray(strName, Array("header End", "task End", "measures End", "system End", "software End", "infrastructure End", "environment End", "$hash End")) Then
                                rowNumber = rowNumber + 2
                            End If
                    'it is not empty so we read the next column
                    Else
                            rowNumber = TableProperties(0) - 1
                            colNumber = colNumber + 1
                            strType = "newCol"
                            i = TableProperties(1)
                    End If
                
                'Si c'est la fin d'un sous-tableau
                ElseIf numTable = 2 Then
                    isItEmpty = ""
                    'si c'est le dernier sous elements d'un sous tableau, pas besoin de checker les lignes suivantes, il ne peut pas y avoir plus d'élements
                    If SubTableProperties(6) = SubTableProperties(5) Then
                            'end of subtable so delete everything
                            rowNumber = rowNumber + 1
                            numTable = numTable - 1
                            tableName = ""
                            strType = "TableEnd"
                            If (previousSubTable(0) = 0) Then
                                previousSubTable(0) = SubTableProperties(3)
                                previousSubTable(1) = SubTableProperties(4)
                            End If
                            SubTableProperties(0) = 0
                            SubTableProperties(1) = 0
                            SubTableProperties(6) = 0
                    'pour check si les lignes du dessous sont vides pour ne pas ajouter d'élements vides dans le tableau
                    Else
                        SubTableProperties(1) = rowNumber
                        SubTableProperties(4) = rowNumber
                        For j = rowNumber + 2 To rowNumber + 2 + (SubTableProperties(1) - SubTableProperties(0))
                            If formSheet.Cells(j, 2).Value = formSheet.Cells(j, 4).Value Then
                                isItEmpty = isItEmpty
                            Else
                               isItEmpty = isItEmpty + CStr(formSheet.Cells(j, colNumber).Value)
                            End If
                        Next j
                        'on saute les lignes pour aller à la suite du formulaire sans prendre en compte le tableau vide
                        'on peut donc fermer le sous tableau
                        If isItEmpty = "" Then
                            SubTableProperties(4) = rowNumber + (SubTableProperties(1) - SubTableProperties(0) + 2) * (SubTableProperties(5) - SubTableProperties(6))
                            rowNumber = SubTableProperties(4) + 1
                            numTable = numTable - 1
                            tableName = ""
                            strType = "TableEnd"
                            If (previousSubTable(0) = 0) Then
                                previousSubTable(0) = SubTableProperties(3)
                                previousSubTable(1) = SubTableProperties(4)
                            End If
                            SubTableProperties(0) = 0
                            SubTableProperties(1) = 0
                            SubTableProperties(6) = 0
                        'on lit les lignes suivantes et on ajoute une ligne newObj dans le rapport
                        Else
                            SubTableProperties(6) = SubTableProperties(6) + 1
                            rowNumber = rowNumber + 1
                            SubTableProperties(0) = rowNumber + 1
                            strType = "newObj"
                            i = SubTableProperties(2)
                        End If
                    
                    End If
                
                End If
                        
            Case "ObjectEnd"
                result = ""
                 If IsInArray(strName, Array("header End", "task End", "measures End", "system End", "software End", "infrastructure End", "environment End", "$hash End")) Then
                    rowNumber = rowNumber + 3
                ElseIf numTable > 1 Then
                End If
                numObject = numObject - 1
                
        End Select

        If strMandatory = True And res Then
            If Cells(rowNumber, colNumber).Value = "" Then
                MsgBox ("Attention le champ est vide or il est obligatoire vérifier vos saisies : " + CStr(rowNumber) + "," + strName)
            End If
        End If
        res = False
        
    If firstline Then
        Worksheets.Add(After:=Worksheets("Formulaire")).Name = ("Save_" + strSaveName)
        
        Sheets("Save_" + strSaveName).Activate
        
        Range("B1").Value = "ID"
        Range("C1").Value = "Context"
        Range("D1").Value = "Category"
        Range("E1").Value = "Name"
        Range("F1").Value = "SubObjects"
        Range("G1").Value = "Type"
        Range("H1").Value = "Mandatory"
        Range("I1").Value = "Auto"
        Range("J1").Value = "CMD"
        Range("K1").Value = "EnumValues"
        Range("L1").Value = "DefaultValue"
        Range("M1").Value = "Question"
        Range("N1").Value = "Comment"
        Range("O1").Value = "Value"

        Range("B1:O2").Select
        ActiveSheet.ListObjects.Add(xlSrcRange, Range("$B$1:$O$2"), , xlYes).Name = strSaveName
        firstline = False
        
        rowsave = (Range(strSaveName).Rows.Count)
        
    Else
        
        rowsave = (Range(strSaveName).Rows.Count + 1)
        
    End If
    
    Range(strSaveName).Cells(rowsave, 1).Value = strID
    Range(strSaveName).Cells(rowsave, 2).Value = strContext
    If nbSubOccurences <> 0 Then
        Range(strSaveName).Cells(rowsave, 3).Value = strCategorie & nbSubOccurences
    Else
        Range(strSaveName).Cells(rowsave, 3).Value = strCategorie
    End If
    Range(strSaveName).Cells(rowsave, 4).Value = strName
    Range(strSaveName).Cells(rowsave, 5).Value = strSubObject
    Range(strSaveName).Cells(rowsave, 6).Value = strType
    Range(strSaveName).Cells(rowsave, 7).Value = strMandatory
    Range(strSaveName).Cells(rowsave, 8).Value = strAuto
    Range(strSaveName).Cells(rowsave, 9).Value = strCmd
    Range(strSaveName).Cells(rowsave, 10).Value = strEnum
    Range(strSaveName).Cells(rowsave, 11).Value = strDefvalue
    Range(strSaveName).Cells(rowsave, 12).Value = strQuestion
    Range(strSaveName).Cells(rowsave, 13).Value = strComment
    Range(strSaveName).Cells(rowsave, 14).Value = result
    
    
    Next i

    Range("A1").Select
    Application.ScreenUpdating = True
    
End Sub

Function read_result_in_form2(formSheet As Worksheet, row As Integer, col As Integer) As String

    Dim result As String
    result = ""
    
    Sheets("Formulaire").Activate
    formSheet.Cells(row, col).Select
    
    result = formSheet.Cells(row, col).Value
    
    read_result_in_form2 = result

End Function


