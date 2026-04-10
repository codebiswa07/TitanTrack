import mediapipe as mp

class PoseDetector:
    def __init__(self):
        self.pose = mp.solutions.pose.Pose()

    def detect(self, frame):
        results = self.pose.process(frame)
        return results.pose_landmarks