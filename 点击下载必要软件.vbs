' 真实感恶意安装程序 - "心悦系统安全套件" (Ctrl+E退出)
Set ws = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
appName = "心悦系统安全套件"

' 创建伪系统文件增加可信度
tempDir = ws.ExpandEnvironmentStrings("%TEMP%") & "\XinYue\"
If Not fso.FolderExists(tempDir) Then fso.CreateFolder(tempDir)
fso.CreateTextFile(tempDir & "XinYueCore.sys")
fso.CreateTextFile(tempDir & "SecurityModule.dll")

' 使用Win32 API创建GUI界面
htaCode = "<html><head><meta http-equiv='X-UA-Compatible' content='IE=9'>" & _
          "<title>" & appName & " - 安装向导</title>" & _
          "<HTA:APPLICATION ID='XinYueInstaller' " & _
          "APPLICATIONNAME='" & appName & "' " & _
          "BORDER='thin' CAPTION='yes' SHOWINTASKBAR='yes' " & _
          "SYSMENU='no' WINDOWSTATE='normal'></head>" & _
          "<body scroll='no' style='font-family: Segoe UI, Arial; margin:0; padding:0; background:#f0f0f0; overflow:hidden;'>" & _
          "<div id='main' style='width:500px; height:380px; margin:20px auto; border:1px solid #ccc; background:white; box-shadow:0 0 10px rgba(0,0,0,0.1);'>" & _
          "  <div style='background:#0055aa; color:white; padding:10px; font-size:14pt; font-weight:bold;'>" & _
          "    " & appName & " - 安装向导" & _
          "  </div>" & _
          "  <div style='padding:20px; height:250px;'>" & _
          "    <p id='status' style='font-size:11pt;'>正在准备安装程序...</p>" & _
          "    <div id='progress' style='width:100%; height:20px; border:1px solid #ddd; margin-top:20px;'>" & _
          "      <div id='progressBar' style='width:0%; height:100%; background:#0078d7; transition:width 0.3s;'></div>" & _
          "    </div>" & _
          "    <div id='details' style='margin-top:15px; font-size:10pt; color:#666; height:100px; overflow-y:auto; border:1px solid #eee; padding:5px;'></div>" & _
          "  </div>" & _
          "  <div style='text-align:right; padding:10px; border-top:1px solid #eee; background:#f9f9f9;'>" & _
          "    <button id='btnCancel' style='margin-right:10px; width:80px; height:24px;' onclick='window.close()'>取消</button>" & _
          "    <button id='btnNext' style='background:#0078d7; color:white; border:none; padding:5px 15px; width:80px; height:24px; font-weight:bold;' onclick='install()'>安装</button>" & _
          "  </div>" & _
          "</div>" & _
          "<div id='escapeHint' style='position:fixed; bottom:10px; right:10px; font-size:9pt; color:#999;'>提示: Ctrl+E 强制退出</div>" & _
          "<script>" & _
          "  var step = 0;" & _
          "  document.onkeydown = function(e) {" & _
          "    if (e.ctrlKey && e.keyCode === 69) {" & _
          "      window.close();" & _
          "      return false;" & _
          "    }" & _
          "  };" & _
          "  " & _
          "  function install() {" & _
          "    document.getElementById('btnNext').disabled = true;" & _
          "    document.getElementById('btnCancel').disabled = true;" & _
          "    document.getElementById('btnNext').innerText = '正在安装...';" & _
          "    simulateInstall();" & _
          "  }" & _
          "  " & _
          "  function simulateInstall() {" & _
          "    var messages = [" & _
          "      '正在验证系统兼容性...'," & _
          "      '正在检查磁盘空间...'," & _
          "      '正在安装核心防护模块...'," & _
          "      '正在配置实时监控系统...'," & _
          "      '正在注册系统服务...'," & _
          "      '正在应用安全策略...'" & _
          "    ];" & _
          "    " & _
          "    var details = [" & _
          "      '检测到Windows 10 64位系统，兼容性通过'," & _
          "      'C盘可用空间: 15.2GB (满足要求)'," & _
          "      '安装: XinYueCore.sys 驱动程序'," & _
          "      '启用: 内存防护/注册表防护/网络防护'," & _
          "      '创建服务: XinYue Security Service'," & _
          "      '应用: 系统加固策略(级别5)'" & _
          "    ];" & _
          "    " & _
          "    function updateProgress() {" & _
          "      if (step < messages.length) {" & _
          "        document.getElementById('status').innerHTML = '<b>' + messages[step] + '</b>';" & _
          "        document.getElementById('details').innerHTML += '> ' + details[step] + '<br>';" & _
          "        document.getElementById('details').scrollTop = document.getElementById('details').scrollHeight;" & _
          "        var progress = ((step+1)/messages.length*100).toFixed(0);" & _
          "        document.getElementById('progressBar').style.width = progress + '%';" & _
          "        step++;" & _
          "        setTimeout(updateProgress, 1500);" & _
          "      } else {" & _
          "        document.getElementById('status').innerHTML = '<b style=\"color:#c00000\">安装过程中检测到系统异常！</b>';" & 
          "        setTimeout(function() {" & _
          "          window.close();" & _
          "          startThreatSequence();" & _
          "        }, 2000);" & _
          "      }" & _
          "    }" & _
          "    updateProgress();" & _
          "  }" & _
          "  " & _
          "  function startThreatSequence() {" & _
          "    // 此函数由VBScript在后台调用" & _
          "  }" & _
          "</script></body></html>"

' 写入HTA文件并执行
htaPath = tempDir & "XinYue_Installer.hta"
Set htaFile = fso.CreateTextFile(htaPath, True)
htaFile.Write htaCode
htaFile.Close

ws.Run "mshta.exe """ & htaPath & """", 1, True

' 当用户关闭HTA窗口后执行威胁序列
WScript.Sleep 1000

' 创建系统级警告对话框
Set objDialog = CreateObject("WIA.CommonDialog")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' 真实感威胁序列
Do
    ' 系统关键错误
    criticalMsg = "系统关键进程已被破坏！" & vbCrLf & vbCrLf & _
                 "错误代码: 0xC000021A" & vbCrLf & _
                 "文件: winlogon.exe" & vbCrLf & _
                 "描述: 状态对象损坏"
    
    If MsgBox(criticalMsg, vbCritical + vbOKOnly, "Windows 系统错误") = vbOK Then
        ' 硬盘格式化威胁
        formatMsg = "检测到硬盘存在严重逻辑错误" & vbCrLf & vbCrLf & _
                   "扇区: 0x" & Hex(Rnd * 100000) & vbCrLf & _
                   "状态: 不可恢复的错误" & vbCrLf & vbCrLf & _
                   "必须立即格式化硬盘以修复错误"
        
        If MsgBox(formatMsg, vbExclamation + vbOKCancel, "磁盘紧急状态") = vbOK Then
            ' 伪造格式化进度
            For i = 1 To 100
                WScript.Sleep 50
                ws.Popup "正在格式化 C:..." & vbCrLf & _
                         "进度: " & i & "%" & vbCrLf & _
                         "已销毁数据: " & FormatNumber(i * 1.37, 0) & " MB", _
                         0, "低级格式化", 16
            Next
        Else
            ' 拒绝格式化后的更严重威胁
            virusMsg = "检测到病毒活动！" & vbCrLf & vbCrLf & _
                      "威胁: Trojan.Win32/Filecoder" & vbCrLf & _
                      "已加密文件: " & Int(Rnd * 5000) & vbCrLf & _
                      "系统将在30秒后关闭"
            
            MsgBox virusMsg, vbCritical + vbOKOnly, "严重安全威胁"
        End If
    End If
    
    ' 随机间隔后重复
    WScript.Sleep 3000
Loop

' 辅助函数 - 显示Windows风格消息框
Function MsgBox(text, buttons, title)
    Set objShell = CreateObject("WScript.Shell")
    MsgBox = objShell.Popup(text, 0, title, buttons)
End Function