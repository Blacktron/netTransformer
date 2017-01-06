/*
 * cisco_sendCommand.groovy
 *
 * This work is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 *
 * This work is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 * USA
 *
 * Copyright (c) 2010-2016 iTransformers Labs. All rights reserved.
 */

/**
 * Created with IntelliJ IDEA.
 * User: niau
 * Date: 1/23/14
 * Time: 3:35 PM
 * To change this template use File | Settings | File Templates.
 */


prompt = ">"
powerUserPrompt = "#"
defaultTerminator = "\r"
logedIn = "false"
logedInPowerMode = "false"
logedInConfigMode = "false"
hostname = ""
status = ["success": 1, "failure": 2]


def result = sendCommand()

return result

def sendCommand() {
    def returnFlag = 2
    def result = null
    String command = params.get("command");
    String evalScript = params.get("eval-script");


//    String command = params.get("command");
    send(command + defaultTerminator)
    expect (command+defaultTerminator)
 //   iterator().getBuffer();
    if (evalScript != null) {
       // println(System.currentTimeMillis())
        def evalResult = evaluate(evalScript)
        if (evalResult["status"] != status["success"]) {
            return ["status": returnFlag, "reportResult": evalResult["reportResult"], "commandResult": evalResult["commandResult"]]
        }
    }
    expect _re(params["hostname"]+powerUserPrompt + "\$") {
        returnFlag = status["success"]
        commandResult = it.getBuffer()
    }
    return ["status": returnFlag, "commandResult": commandResult]


}