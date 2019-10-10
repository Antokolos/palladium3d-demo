extends MultiMeshInstance

func set_quality_normal():
	multimesh.set_visible_instance_count(128)

func set_quality_optimal():
	multimesh.set_visible_instance_count(256)

func set_quality_good():
	multimesh.set_visible_instance_count(512)

func set_quality_high():
	multimesh.set_visible_instance_count(1024)