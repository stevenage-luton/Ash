using Godot;
using System;

public partial class Player : CharacterBody3D
{

	const float speed = 3f;
	private float cameraAngle = 0F;
	const float gravity = 9f;
	const float acceleration = 0.5f;
	const float sensitivity = 0.4f;

	bool FloorConstantSpeed = true;
	public Node3D head;
	public Camera3D cam;
	
	public Node3D groundCheck;

	float initialSeperation;

	private AudioStreamPlayer3D footstepSounds;
	private AudioStream stepSample;
	private int previousStep = 0;
	public Timer stepTimer;

	private Vector3 velocity = Vector3.Zero;
	
	private RandomNumberGenerator random;

	[Export]
	private float stepInterval = 0.6f;

	

	public override void _Ready(){
		head = GetNode<Node3D>("Head");
		cam = GetNode<Camera3D>("Head/PlayerCamera");
		stepTimer = GetNode<Timer>("FootstepTimer");
		footstepSounds = GetNode<AudioStreamPlayer3D>("FootstepSounds");
		Input.MouseMode = Input.MouseModeEnum.Captured;
		random = new RandomNumberGenerator();
		random.Randomize();
	}

	public override void _Process(double delta)
    {
        if (Input.IsActionPressed("ui_cancel"))
            Input.MouseMode = Input.MouseModeEnum.Visible;
    }

    public override void _Input(InputEvent @event)
    {
        if (@event is not InputEventMouseMotion motion) return;

        head.RotateY(Mathf.DegToRad(-motion.Relative.X * sensitivity));
        float change = -motion.Relative.Y * sensitivity;

        if (!((change + cameraAngle) < 90F) || !((change + cameraAngle) > -90F)) return;

        cam.RotateX(Mathf.DegToRad(change));
        cameraAngle += change;
    }

	public override void _PhysicsProcess(double delta){
		Vector2 inputDir = Input.GetVector("left","right","up","down");
		Vector3 direction = (head.GlobalTransform.Basis * new Vector3(inputDir.X, 0 ,inputDir.Y)).Normalized();
		float tempSpeed = speed;

		if(inputDir.Y > 0){
			tempSpeed = 2.0f;
			stepInterval = 0.75f;
		}else{
			stepInterval = 0.6f;
		}

		if(direction != Vector3.Zero){
			velocity.X = direction.X * tempSpeed;
			velocity.Z = direction.Z * tempSpeed;
		}else{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, acceleration);
			velocity.Z = Mathf.MoveToward(Velocity.Z, 0, acceleration);
		}

		if(!IsOnFloor()){
			velocity.Y -= gravity * (float)delta;
		}

		Velocity = velocity;
		if (inputDir.Length() == 0){

		}else if(stepTimer.IsStopped()){
			PlayFootStepSound();
			stepTimer.Start(stepInterval);
		}
		MoveAndSlide();

	}

	public void PlayFootStepSound(){
		int randFootstep = random.RandiRange(0, 6);
		while (randFootstep == previousStep){
			randFootstep = random.RandiRange(0, 6);
		}
		switch(randFootstep){
			case 0:
				stepSample = ResourceLoader.Load<AudioStream>("res://Sounds/Footstep1.ogg");
				break;
			case 1:
				stepSample = ResourceLoader.Load<AudioStream>("res://Sounds/Footstep2.ogg");
				break;
			case 2:
				stepSample = ResourceLoader.Load<AudioStream>("res://Sounds/Footstep3.ogg");
				break;
			case 3:
				stepSample = ResourceLoader.Load<AudioStream>("res://Sounds/Footstep4.ogg");
				break;
			case 4:
				stepSample = ResourceLoader.Load<AudioStream>("res://Sounds/Footstep5.ogg");
				break;
			case 5:
				stepSample = ResourceLoader.Load<AudioStream>("res://Sounds/Footstep6.ogg");
				break;
		}
		footstepSounds.Stream = stepSample;
		footstepSounds.PitchScale = random.RandfRange(0.8f, 1.2f);
		footstepSounds.Play();
		previousStep = randFootstep;
	}
}
