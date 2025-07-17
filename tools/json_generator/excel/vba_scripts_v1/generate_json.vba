Option Explicit

Sub generate_json()
    
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
    Dim strValue     As String
    Dim numTable     As Integer
    Dim i            As Integer
    Dim nbSubComponents As Integer
    Dim rowNumber    As Integer
    Dim rowsave      As Integer
    Dim colNumber    As Integer
    Dim numObject    As Integer
    Dim firstline    As Boolean
    Dim strSaveName As String
    Dim strRestoName As String
    Dim result As String
    Dim startTable As Integer
    Dim rowNumTable As Integer
    Dim isItEmpty As String
    Dim j As Integer
    Dim indent As Integer
    Dim nextStrType As String
    Dim endline As String
    
    Dim tableName As String
    
    Dim formSheet As Worksheet
    Dim sampleInfraSheet As Worksheet
    
    'Initialisation du contexte
    Set sampleInfraSheet = Worksheets("Reference")
    Set formSheet = Worksheets("Formulaire")
    
    Sheets("Formulaire").Activate
    
    rowNumber = 12
    numObject = 0
    numTable = 0
    res = False
    firstline = True
    
    Application.ScreenUpdating = False
    
    strSaveName = Range("C9").Value
    strRestoName = Range("C8").Value
    
    colNumber = 4
    
    Dim ruta As String
    Dim fi As Long

    fi = FreeFile

    'Edit to put your own path
    ruta = ThisWorkbook.Path & "\report.json"
    
    On Error GoTo Err
    Open ruta For Output As #fi
    On Error GoTo 0
    'Application.DisplayAlerts = False
    
    
    Print #fi, "{"

    Dim indentNb As Integer
    
    indentNb = 1
    indent = 0
    
    'For each row of my sample_infra sheet
    For i = 1 To (Range(strSaveName).Rows.Count)
        'Get the categorie of the fiels, if is it a basic field we can continue
        strID = Range(strSaveName).Cells(i, 1).Value
        strContext = Range(strSaveName).Cells(i, 2).Value
        strCategorie = Range(strSaveName).Cells(i, 3).Value
        strName = Range(strSaveName).Cells(i, 4).Value
        strSubObject = Range(strSaveName).Cells(i, 5).Value
        strType = Range(strSaveName).Cells(i, 6).Value
        strMandatory = Range(strSaveName).Cells(i, 7).Value
        strAuto = Range(strSaveName).Cells(i, 8).Value
        strCmd = Range(strSaveName).Cells(i, 9).Value
        strEnum = Range(strSaveName).Cells(i, 10).Value
        strDefvalue = Range(strSaveName).Cells(i, 11).Value
        strQuestion = Range(strSaveName).Cells(i, 12).Value
        strComment = Range(strSaveName).Cells(i, 13).Value
        strValue = Range(strSaveName).Cells(i, 14).Value
        
        nextStrType = Range(strSaveName).Cells(i + 1, 6).Value
        
        If nextStrType <> "ObjectEnd" And nextStrType <> "newCol" And nextStrType <> "TableEnd" And nextStrType <> "" Then
        
            endline = ","
        
        Else
        
            endline = ""
        
        End If
        
        
        Select Case strCategorie
        
            Case "basicField"
        
            Case tableName
            
        End Select
                    
        Select Case strType
            
            Case "Object"
                Print #fi, indentification(indent) + """" + strName + """" + ": {"
                indent = indent + 1
                numObject = numObject + 1
                
            Case "Enum", "String", "Integer", "Float"
                Print #fi, indentification(indent) + """" + strName + """" + ": " + """" + strValue + """" + endline
            
            Case "Table"
                Print #fi, indentification(indent) + """" + strName + """" + ": ["
                indent = indent + 1
                Print #fi, indentification(indent) + "{"
                indent = indent + 1

            
            Case "TableEnd"
                indent = indent - 1
                Print #fi, indentification(indent) + "}"
                indent = indent - 1
                Print #fi, indentification(indent) + "]" + endline

                
            Case "ObjectEnd"
                indent = indent - 1
                Print #fi, indentification(indent) + "}" + endline
                numObject = numObject - 1
                
                
            Case "newCol", "newObj"
                indent = indent - 1
                Print #fi, indentification(indent) + "}" + endline
                Print #fi, indentification(indent) + "{"
                indent = indent + 1
                
        End Select
        
    endline = ""
    
    Next i
    Range("A1").Select
    Application.ScreenUpdating = True
    
    Print #fi, "}"
    
    Close #fi
    
Err:
    Close #fi
    
End Sub

Function indentification(num As Integer)

    Dim result As String
    Dim i As Integer
    
    result = ""
    
    For i = 0 To num
    
        result = result + Chr(9)
    
    Next
    
    indentification = result

End Function
