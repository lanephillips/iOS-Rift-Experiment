/************************************************************************************
 
 Filename    :   RenderTiny_GL_Device.cpp
 Content     :   RenderDevice implementation for OpenGL (tiny version)
 Created     :   September 10, 2012
 Authors     :   Andrew Reisse, Artem Bolgar
 
 Copyright   :   Copyright 2012 Oculus, Inc. All Rights reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 ************************************************************************************/

uniform mat4 View;
uniform mat4 Texm;
attribute vec4 Position;
attribute vec2 TexCoord;
varying  vec2 oTexCoord;

void main()
{
    gl_Position = View * Position;
    oTexCoord = vec2(Texm * vec4(TexCoord,0,1));
    oTexCoord.y = 1.0-oTexCoord.y;
}
