defmodule UserDocs.AutomationTest do
  use UserDocs.DataCase

  alias UserDocs.Automation

  describe "step_types" do
    alias UserDocs.Automation.StepType

    @valid_attrs %{args: [], name: "some name"}
    @update_attrs %{args: [], name: "some updated name"}
    @invalid_attrs %{args: nil, name: nil}

    def step_type_fixture(attrs \\ %{}) do
      {:ok, step_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Automation.create_step_type()

      step_type
    end

    test "list_step_types/0 returns all step_types" do
      step_type = step_type_fixture()
      assert Automation.list_step_types() == [step_type]
    end

    test "get_step_type!/1 returns the step_type with given id" do
      step_type = step_type_fixture()
      assert Automation.get_step_type!(step_type.id) == step_type
    end

    test "create_step_type/1 with valid data creates a step_type" do
      assert {:ok, %StepType{} = step_type} = Automation.create_step_type(@valid_attrs)
      assert step_type.args == []
      assert step_type.name == "some name"
    end

    test "create_step_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Automation.create_step_type(@invalid_attrs)
    end

    test "update_step_type/2 with valid data updates the step_type" do
      step_type = step_type_fixture()
      assert {:ok, %StepType{} = step_type} = Automation.update_step_type(step_type, @update_attrs)
      assert step_type.args == []
      assert step_type.name == "some updated name"
    end

    test "update_step_type/2 with invalid data returns error changeset" do
      step_type = step_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Automation.update_step_type(step_type, @invalid_attrs)
      assert step_type == Automation.get_step_type!(step_type.id)
    end

    test "delete_step_type/1 deletes the step_type" do
      step_type = step_type_fixture()
      assert {:ok, %StepType{}} = Automation.delete_step_type(step_type)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_step_type!(step_type.id) end
    end

    test "change_step_type/1 returns a step_type changeset" do
      step_type = step_type_fixture()
      assert %Ecto.Changeset{} = Automation.change_step_type(step_type)
    end
  end

  describe "steps" do
    alias UserDocs.Automation.Step

    @valid_attrs %{order: 42}
    @update_attrs %{order: 43}
    @invalid_attrs %{order: nil}

    def step_fixture(attrs \\ %{}) do
      {:ok, step} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Automation.create_step()

      step
    end

    test "list_steps/0 returns all steps" do
      step = step_fixture()
      assert Automation.list_steps() == [step]
    end

    test "get_step!/1 returns the step with given id" do
      step = step_fixture()
      assert Automation.get_step!(step.id) == step
    end

    test "create_step/1 with valid data creates a step" do
      assert {:ok, %Step{} = step} = Automation.create_step(@valid_attrs)
      assert step.order == 42
    end

    test "create_step/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Automation.create_step(@invalid_attrs)
    end

    test "update_step/2 with valid data updates the step" do
      step = step_fixture()
      assert {:ok, %Step{} = step} = Automation.update_step(step, @update_attrs)
      assert step.order == 43
    end

    test "update_step/2 with invalid data returns error changeset" do
      step = step_fixture()
      assert {:error, %Ecto.Changeset{}} = Automation.update_step(step, @invalid_attrs)
      assert step == Automation.get_step!(step.id)
    end

    test "delete_step/1 deletes the step" do
      step = step_fixture()
      assert {:ok, %Step{}} = Automation.delete_step(step)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_step!(step.id) end
    end

    test "change_step/1 returns a step changeset" do
      step = step_fixture()
      assert %Ecto.Changeset{} = Automation.change_step(step)
    end
  end

  describe "jobs" do
    alias UserDocs.Automation.Job

    @valid_attrs %{job_type: "some job_type"}
    @update_attrs %{job_type: "some updated job_type"}
    @invalid_attrs %{job_type: nil}

    def job_fixture(attrs \\ %{}) do
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Automation.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Automation.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Automation.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      assert {:ok, %Job{} = job} = Automation.create_job(@valid_attrs)
      assert job.job_type == "some job_type"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Automation.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, %Job{} = job} = Automation.update_job(job, @update_attrs)
      assert job.job_type == "some updated job_type"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Automation.update_job(job, @invalid_attrs)
      assert job == Automation.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Automation.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Automation.change_job(job)
    end
  end

  describe "args" do
    alias UserDocs.Automation.Arg

    @valid_attrs %{key: "some key", value: "some value"}
    @update_attrs %{key: "some updated key", value: "some updated value"}
    @invalid_attrs %{key: nil, value: nil}

    def arg_fixture(attrs \\ %{}) do
      {:ok, arg} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Automation.create_arg()

      arg
    end

    test "list_args/0 returns all args" do
      arg = arg_fixture()
      assert Automation.list_args() == [arg]
    end

    test "get_arg!/1 returns the arg with given id" do
      arg = arg_fixture()
      assert Automation.get_arg!(arg.id) == arg
    end

    test "create_arg/1 with valid data creates a arg" do
      assert {:ok, %Arg{} = arg} = Automation.create_arg(@valid_attrs)
      assert arg.key == "some key"
      assert arg.value == "some value"
    end

    test "create_arg/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Automation.create_arg(@invalid_attrs)
    end

    test "update_arg/2 with valid data updates the arg" do
      arg = arg_fixture()
      assert {:ok, %Arg{} = arg} = Automation.update_arg(arg, @update_attrs)
      assert arg.key == "some updated key"
      assert arg.value == "some updated value"
    end

    test "update_arg/2 with invalid data returns error changeset" do
      arg = arg_fixture()
      assert {:error, %Ecto.Changeset{}} = Automation.update_arg(arg, @invalid_attrs)
      assert arg == Automation.get_arg!(arg.id)
    end

    test "delete_arg/1 deletes the arg" do
      arg = arg_fixture()
      assert {:ok, %Arg{}} = Automation.delete_arg(arg)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_arg!(arg.id) end
    end

    test "change_arg/1 returns a arg changeset" do
      arg = arg_fixture()
      assert %Ecto.Changeset{} = Automation.change_arg(arg)
    end
  end

  describe "processes" do
    alias UserDocs.Automation.Process

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def process_fixture(attrs \\ %{}) do
      {:ok, process} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Automation.create_process()

      process
    end

    test "list_processes/0 returns all processes" do
      process = process_fixture()
      assert Automation.list_processes() == [process]
    end

    test "get_process!/1 returns the process with given id" do
      process = process_fixture()
      assert Automation.get_process!(process.id) == process
    end

    test "create_process/1 with valid data creates a process" do
      assert {:ok, %Process{} = process} = Automation.create_process(@valid_attrs)
      assert process.name == "some name"
    end

    test "create_process/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Automation.create_process(@invalid_attrs)
    end

    test "update_process/2 with valid data updates the process" do
      process = process_fixture()
      assert {:ok, %Process{} = process} = Automation.update_process(process, @update_attrs)
      assert process.name == "some updated name"
    end

    test "update_process/2 with invalid data returns error changeset" do
      process = process_fixture()
      assert {:error, %Ecto.Changeset{}} = Automation.update_process(process, @invalid_attrs)
      assert process == Automation.get_process!(process.id)
    end

    test "delete_process/1 deletes the process" do
      process = process_fixture()
      assert {:ok, %Process{}} = Automation.delete_process(process)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_process!(process.id) end
    end

    test "change_process/1 returns a process changeset" do
      process = process_fixture()
      assert %Ecto.Changeset{} = Automation.change_process(process)
    end
  end
end
