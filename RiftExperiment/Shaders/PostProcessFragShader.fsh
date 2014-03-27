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

uniform vec2 LensCenter;
uniform vec2 ScreenCenter;
uniform vec2 Scale;
uniform vec2 ScaleIn;
uniform vec4 HmdWarpParam;
uniform sampler2D Texture0;
varying vec2 oTexCoord;

vec2 HmdWarp(vec2 in01)
{
   vec2  theta = (in01 - LensCenter) * ScaleIn; // Scales to [-1, 1]
   float rSq = theta.x * theta.x + theta.y * theta.y;
   vec2  theta1 = theta * (HmdWarpParam.x + HmdWarpParam.y * rSq +
                           HmdWarpParam.z * rSq * rSq + HmdWarpParam.w * rSq * rSq * rSq);
   return LensCenter + Scale * theta1;
}

void main()
{
   vec2 tc = HmdWarp(oTexCoord);
   if (!all(equal(clamp(tc, ScreenCenter-vec2(0.25,0.5), ScreenCenter+vec2(0.25,0.5)), tc)))
       gl_FragColor = vec4(0);
   else
       gl_FragColor = texture2D(Texture0, tc);
}