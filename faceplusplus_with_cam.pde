import http.requests.*; // add lib "http requests for processing"
import processing.video.*; // add lib "video"

/* PREFS */
String api_key = "";
String api_secret = "";

boolean useCam = true;
String defaultPath = "lena.jpg"; // replace with /data/image for onetime analysis


Capture cam;
PImage photo;

String camPath = "";
String debugText = "Press Spacebar";

PostRequest post; 

public void setup() 
{
  size(640, 480); 


  //CAMERA SETUP
  // just use default
  cam = new Capture(this, 640, 480);
  cam.start();

  if (!useCam) {
    photo = loadImage(defaultPath); 
    analyzeFace(defaultPath);
  }
}

void draw()
{
  if (useCam) {
    if (cam.available()) {
      cam.read();
      image(cam, 0, 0);
    }
  } else {
    image(photo, 0, 0);
  }

  fill(0, 255, 0);
  text(debugText, 10, 10, width-20, height-20);
}

void keyPressed() {

  // switch to live cam
  if (key == 'c') {
    if (useCam) {
      useCam = false;
    } else {
      useCam = true;
    }
  }

  // take and anaylze cam picture
  if (keyCode == 32) {
    if (useCam) {
      String date = new java.text.SimpleDateFormat("yyyy_MM_dd_kkmmss").format(new java.util.Date ()); 
      camPath = "cam_"+date+".jpg";
      cam.save("data/"+camPath);
      debugText = "Processing...";
      photo = loadImage(camPath);
      analyzeFace(camPath);
      useCam = false;
    } else {
      useCam = true;
    }
  }
}

void analyzeFace(String imgPath) {
  // POST DETECT FACE
  post = new PostRequest("https://api-us.faceplusplus.com/facepp/v3/detect");
  post.addData("api_key", api_key);
  post.addData("api_secret", api_secret);

  //requires fullpath to image v
  post.addFile("image_file", dataPath(imgPath));

  post.send();
  println(post.getContent());

  // PARSE DETECT FACE
  JSONObject response = parseJSONObject(post.getContent());
  JSONArray faces = response.getJSONArray("faces");
  JSONObject attribute = faces.getJSONObject(0);
  String face_token = attribute.getString("face_token");

  // POST GET ATTRIBUTES
  post = new PostRequest("https://api-us.faceplusplus.com/facepp/v3/face/analyze");
  post.addData("api_key", api_key);
  post.addData("api_secret", api_secret);
  post.addData("return_landmark", "0"); // set to 1 for landmarks
  post.addData("return_attributes", "gender,age,smiling,headpose,facequality,blur,eyestatus,ethnicity");
  post.addData("face_tokens", face_token);

  post.send();
  println(post.getContent());

  // extract JSON values from above

  debugText = post.getContent();
}
