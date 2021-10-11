object Main: TMain
  Left = 240
  Top = 130
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'VKSSoft - Kill Process'
  ClientHeight = 424
  ClientWidth = 508
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormShow
  OnCreate = FormCreate
  OnDeactivate = FormShow
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 168
    Top = 302
    Width = 17
    Height = 16
    Caption = '1 c'
  end
  object Label2: TLabel
    Left = 8
    Top = 280
    Width = 68
    Height = 16
    Caption = #1048#1085#1090#1077#1088#1074#1072#1083':'
  end
  object Label3: TLabel
    Left = 232
    Top = 344
    Width = 231
    Height = 16
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1083#1086#1075#1080#1095#1077#1089#1082#1080#1093' '#1087#1088#1086#1094#1077#1089#1089#1086#1074':'
  end
  object Label4: TLabel
    Left = 472
    Top = 344
    Width = 7
    Height = 16
    Caption = '0'
  end
  object Label5: TLabel
    Left = 8
    Top = 368
    Width = 132
    Height = 16
    Caption = 'Windows '#1079#1072#1087#1091#1097#1077#1085#1072'...'
  end
  object Label6: TLabel
    Left = 8
    Top = 384
    Width = 120
    Height = 16
    Caption = #1055#1088#1086#1096#1083#1086' '#1074#1088#1077#1084#1077#1085#1080'...'
  end
  object Button1: TButton
    Left = 312
    Top = 280
    Width = 185
    Height = 25
    Caption = 'Kill'
    TabOrder = 0
    OnClick = Button1Click
  end
  object TrackBar1: TTrackBar
    Left = 8
    Top = 303
    Width = 153
    Height = 26
    Max = 5
    Min = 1
    Position = 1
    TabOrder = 1
    ThumbLength = 14
    OnChange = TrackBar1Change
  end
  object ListView2: TListView
    Left = 0
    Top = 0
    Width = 508
    Height = 267
    Align = alTop
    BorderStyle = bsNone
    Columns = <
      item
        Caption = 'Process name'
        Width = 123
      end
      item
        Caption = 'Priority'
        Width = 62
      end
      item
        Caption = 'Location'
        Width = 222
      end
      item
        Caption = 'Size'
        Width = 62
      end>
    ColumnClick = False
    FullDrag = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 405
    Width = 508
    Height = 19
    Panels = <
      item
        Text = #1055#1088#1086#1089#1084#1086#1090#1088'...'
        Width = 200
      end
      item
        Text = #1047#1072#1075#1088#1091#1079#1082#1072' '#1062#1055':'
        Width = 50
      end>
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 336
    Width = 114
    Height = 17
    Caption = #1054#1073#1085#1086#1074#1083#1103#1090#1100
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object Button2: TButton
    Left = 312
    Top = 312
    Width = 185
    Height = 25
    Caption = 'Execute'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Timer1: TTimer
    Interval = 3000
    OnTimer = Timer1Timer
    Left = 184
    Top = 232
  end
end
