function [linear_vel, angular_vel, carrot_pose] = regulated_pure_pursuit(transformed_plan, vel, params)

  % Find look ahead distance and point on path and publish
  lookahead_dist = get_lookahead_distance(vel(1), vel(2), params);

  % Check for reverse driving
  if (params.allow_reversing)
    % Cusp check
    dist_to_cusp = findVelocitySignChange(transformed_plan);

    % if the lookahead distance is further than the cusp, use the cusp distance instead
    if (dist_to_cusp < lookahead_dist) 
      lookahead_dist = dist_to_cusp;
    end
  end

  % Get the particular point on the path at the lookahead distance
  carrot_pose = get_lookahead_point(lookahead_dist, transformed_plan, ...
      params.interpolate_curvature_after_goal);
  rotate_to_path_carrot_pose = carrot_pose;

  lookahead_curvature = calculate_curvature(carrot_pose(1), carrot_pose(2));

  regulation_curvature = lookahead_curvature;
  if (params.use_fixed_curvature_lookahead)
    curvature_lookahead_pose = get_lookahead_point( ...
          params.curvature_lookahead_dist, ...
          transformed_plan, params.interpolate_curvature_after_goal);
    rotate_to_path_carrot_pose = curvature_lookahead_pose;
    regulation_curvature = calculate_curvature(curvature_lookahead_pose(1), curvature_lookahead_pose(2));
    carrot_pose = curvature_lookahead_pose;
  end

  % Setting the velocity direction
  x_vel_sign = 1.0;
  if (params.allow_reversing) 
      if carrot_pose(1) >= 0.0
          x_vel_sign = 1.0;
      else
          x_vel_sign = -1.0;
      end
  end

  linear_vel = params.desired_linear_vel;

  % Make sure we're in compliance with basic constraints
  % For shouldRotateToPath, using x_vel_sign in order to support allow_reversing
  % and rotate_to_path_carrot_pose for the direction carrot pose:
  %        - equal to "normal" carrot_pose when curvature_lookahead_pose = false
  %        - otherwise equal to curvature_lookahead_pose (which can be interpolated after goal)
  if (shouldRotateToGoalHeading(carrot_pose(1), carrot_pose(2), params))
    is_rotating_to_heading = true;
    angle_to_goal = transformed_plan(end, 3);
    [linear_vel, angular_vel] = rotateToHeading(angle_to_goal, vel(3), params);
  else
      [angle_to_path, b] = shouldRotateToPath(rotate_to_path_carrot_pose(1), ...
          rotate_to_path_carrot_pose(2), x_vel_sign, params);
      if b
        is_rotating_to_heading = true;
        [linear_vel, angular_vel] = rotateToHeading(angle_to_path, vel(3), params);
      else
        is_rotating_to_heading = false;
        linear_vel = apply_constraints( ...
          regulation_curvature, ...
          transformed_plan, linear_vel, x_vel_sign, params);
            % Apply curvature to angular velocity after constraining linear velocity
        angular_vel = linear_vel * regulation_curvature;  
        if abs(angular_vel) > params.max_angular_vel
            angular_vel = sign(angular_vel) * params.max_angular_vel;
            linear_vel = angular_vel / regulation_curvature;
        end
      end


  end
end


function lookahead_dist = get_lookahead_distance(vel_x, vel_y, params)

  %If using velocity-scaled look ahead distances, find and clamp the dist
  %Else, use the static look ahead distance
  lookahead_dist = params.lookahead_dist;
  if params.use_velocity_scaled_lookahead_dist
      lookahead_dist = abs(vel_x) * params.lookahead_time;
      lookahead_dist = clamp(lookahead_dist, params.min_lookahead_dist, params.max_lookahead_dist);
  end
end


function y = clamp(x, bl, bu)
  y=min(max(x,bl),bu);
end


function c = calculate_curvature(lookahead_point_x, lookahead_point_y)
  % Find distance^2 to look ahead point (carrot) in robot base frame
  % This is the chord length of the circle
  carrot_dist2 = ...
    (lookahead_point_x * lookahead_point_x) + ...
    (lookahead_point_y * lookahead_point_y);

  % Find curvature of circle (k = 1 / R)
  if (carrot_dist2 > 0.001) 
    c = 2.0 * lookahead_point_y / carrot_dist2;
  else 
    c = 0.0;
  end

end




function [angle_to_path, b] = shouldRotateToPath(carrot_x, carrot_y, x_vel_sign, params)

  % Whether we should rotate robot to rough path heading
  angle_to_path = atan2(carrot_y, carrot_x);
  % In case we are reversing
  if (x_vel_sign < 0.0) 
      angle_to_path = wrap_to_pi(angle_to_path + pi);
  end
  b = params.use_rotate_to_heading && ...
         abs(angle_to_path) > params.rotate_to_heading_min_angle;
end

function b = shouldRotateToGoalHeading(carrot_x, carrot_y, params)

  % Whether we should rotate robot to goal heading
  dist_to_goal = sqrt(carrot_x * carrot_x + carrot_y * carrot_y);
  b = params.use_rotate_to_heading && dist_to_goal < params.goal_dist_tol;
  b = 0;
end

function [linear_vel, angular_vel] = rotateToHeading(angle_to_path, curr_speed_yaw, params)

  % Rotate in place using max angular velocity / acceleration possible
  linear_vel = 0.0;
  if angle_to_path > 0.0
      sign = 1.0;
  else
      sign = -1.0;
  end
  angular_vel = sign * params.rotate_to_heading_angular_vel;

  dt = params.dt;
  min_feasible_angular_speed = curr_speed_yaw - params.max_angular_accel * dt;
  max_feasible_angular_speed = curr_speed_yaw + params.max_angular_accel * dt;
  angular_vel = clamp(angular_vel, min_feasible_angular_speed, max_feasible_angular_speed);
end

function p = circleSegmentIntersection(p1, p2, r)
  % Formula for intersection of a line with a circle centered at the origin,
  % modified to always return the point that is on the segment between the two points.
  % https://mathworld.wolfram.com/Circle-LineIntersection.html
  % This works because the poses are transformed into the robot frame.
  % This can be derived from solving the system of equations of a line and a circle
  % which results in something that is just a reformulation of the quadratic formula.
  % Interactive illustration in doc/circle-segment-intersection.ipynb as well as at
  % https://www.desmos.com/calculator/td5cwbuocd
  x1 = p1(1);
  x2 = p2(1);
  y1 = p1(2);
  y2 = p2(2);

  dx = x2 - x1;
  dy = y2 - y1;
  dr2 = dx * dx + dy * dy;
  D = x1 * y2 - x2 * y1;

  % Augmentation to only return point within segment
  d1 = x1 * x1 + y1 * y1;
  d2 = x2 * x2 + y2 * y2;
  dd = d2 - d1;

  sqrt_term = sqrt(r * r * dr2 - D * D);
  p = [(D * dy + sign(dd) * dx * sqrt_term) / dr2, ...
    (-D * dx + sign(dd) * dy * sqrt_term) / dr2];
end

function p = get_lookahead_point(lookahead_dist, transformed_plan, interpolate_after_goal)

  % Find the first pose which is at a distance greater than the lookahead distance
  % auto goal_pose_it = std::find_if(
  %   transformed_plan.poses.begin(), transformed_plan.poses.end(), [&](const auto & ps) {
  %     return sqrt(ps.pose.position.x, ps.pose.position.y) >= lookahead_dist;
  %   });

  goal_pose_idx = arrayfun(@(x, y) sqrt(x * x + y * y) >= lookahead_dist, transformed_plan(:, 1), transformed_plan(:, 2));
  idx = find(goal_pose_idx, 1, 'first');

  % If the no pose is not far enough, take the last pose
  if ~any(goal_pose_idx) 
      if interpolate_after_goal
          last_pose = transformed_plan(end, :);
          prev_last_pose = transformed_plan(end-1, :);
        
          end_path_orientation = atan2(... 
            last_pose(2) - prev_last_pose(2), ...
              last_pose(1) - prev_last_pose(1));
        
          % Project the last segment out to guarantee it is beyond the look ahead
          % distance
          projected_position = [last_pose(1) + cos(end_path_orientation) * lookahead_dist,
            last_pose(2) + sin(end_path_orientation) * lookahead_dist];
        
          % Use the circle intersection to find the position at the correct look
          % ahead distance
          interpolated_position = circleSegmentIntersection(...
                last_pose, projected_position, lookahead_dist);
        
          p = interpolated_position;
      else 
          p = transformed_plan(end, 1:2);
      end
  elseif (idx > 1)
    % Find the point on the line segment between the two poses
    % that is exactly the lookahead distance away from the robot pose (the origin)
    % This can be found with a closed form for the intersection of a segment and a circle
    % Because of the way we did the std::find_if, prev_pose is guaranteed to be inside the circle,
    % and goal_pose is guaranteed to be outside the circle.

    prev_pose = transformed_plan(idx-1, :);
    goal_pose = transformed_plan(idx, :);
    point = circleSegmentIntersection( ...
          prev_pose, ...
          goal_pose, lookahead_dist);
    p = point;
  else
    p = transformed_plan(idx, 1:2);
  end
end

function linear_vel = apply_constraints(curvature, path, linear_vel, sign, params)

  curvature_vel = linear_vel;
  cost_vel = linear_vel;

  % limit the linear velocity by curvature
  if (params.use_regulated_linear_velocity_scaling)
    curvature_vel = curvatureConstraint( ...
      linear_vel, curvature, params.regulated_linear_scaling_min_radius);
  end

  % limit the linear velocity by proximity to obstacles
  % NOT USED
  % if (params.use_cost_regulated_linear_velocity_scaling)
  %   cost_vel = costConstraint(linear_vel, pose_cost, costmap_ros_, params_);
  % end

  % Use the lowest of the 2 constraints, but above the minimum translational speed
  linear_vel = min(cost_vel, curvature_vel);
  linear_vel = max(linear_vel, params.regulated_linear_scaling_min_speed);

  % Apply constraint to reduce speed on approach to the final goal pose
  linear_vel = approachVelocityConstraint( ...
    linear_vel, path, params.min_approach_linear_velocity, ...
    params.approach_velocity_scaling_dist);

  % Limit linear velocities to be valid
  linear_vel = clamp(abs(linear_vel), 0.0, params.desired_linear_vel);
  linear_vel = sign * linear_vel;
end


function s = findVelocitySignChange(transformed_plan)

  % Iterating through the transformed global path to determine the position of the cusp
  for pose_id=2:height(transformed_plan)-1

    % We have two vectors for the dot product OA and AB. Determining the vectors.
    oa_x = transformed_plan(pose_id, 1) - ...
      transformed_plan(pose_id - 1, 1);
    oa_y = transformed_plan(pose_id, 2) - ...
      transformed_plan(pose_id - 1, 2);
    ab_x = transformed_plan(pose_id + 1, 1) - ...
      transformed_plan(pose_id, 1);
    ab_y = transformed_plan(pose_id + 1, 2) - ...
      transformed_plan(pose_id, 2);

    % Checking for the existence of cusp, in the path, using the dot product
    %and determine it's distance from the robot. If there is no cusp in the path,
    %then just determine the distance to the goal location.
    dot_prod = (oa_x * ab_x) + (oa_y * ab_y);
    hypot = @(x, y) sqrt(x*x + y*y);

    if (dot_prod < 0.0)
      % returning the distance if there is a cusp
      % The transformed path is in the robots frame, so robot is at the origin
      x = transformed_plan(pose_id, 1);
      y = transformed_plan(pose_id, 1);
      s = hypot(x, y);
      return
        
    end


    if ( ...
      hypot(oa_x, oa_y) == 0.0 && ...
      transformed_plan(pose_id - 1, 3) ~= ...
      transformed_plan(pose_id, 3) ...
      || ...
      (hypot(ab_x, ab_y) == 0.0 && ...
      transformed_plan(pose_id, 3) ~= ...
      transformed_plan(pose_id + 1, 3)))
    
      % returning the distance since the points overlap
      % but are not simply duplicate points (e.g. in place rotation)
      s =  hypot( ...
        transformed_plan(pose_id, 1), ...
        transformed_plan(pose_id, 2));
      return
    end
  end

  s = inf;
end



function c = curvatureConstraint(raw_linear_vel, curvature, min_radius)
  radius = abs(1.0 / curvature);
  if (radius < min_radius) 
    c = raw_linear_vel * (1.0 - (abs(radius - min_radius) / min_radius));
  else
    c = raw_linear_vel;
  end
end

function v = approachVelocityScalingFactor(transformed_path, approach_velocity_scaling_dist)
  % Waiting to apply the threshold based on integrated distance ensures we don't
  % erroneously apply approach scaling on curvy paths that are contained in a large local costmap.
  remaining_distance = calculate_path_length(transformed_path, 1);
  if (remaining_distance < approach_velocity_scaling_dist)
    last = transformed_path(end, :);
    % Here we will use a regular euclidean distance from the robot frame (origin)
    % to get smooth scaling, regardless of path density.
    d = sqrt(last(1) * last(1) + last(2) * last(2));
    v = d / approach_velocity_scaling_dist;
  else
    v =  1.0;
  end
end


function v = approachVelocityConstraint(constrained_linear_vel, path, ...
        min_approach_velocity, approach_velocity_scaling_dist)

  velocity_scaling = approachVelocityScalingFactor(path, approach_velocity_scaling_dist);
  approach_vel = constrained_linear_vel * velocity_scaling;

  if (approach_vel < min_approach_velocity)
    approach_vel = min_approach_velocity;
  end

  v = min(constrained_linear_vel, approach_vel);
end


function l = calculate_path_length(path, start_index)

  if (start_index + 1 > height(path))
      l = 0.0;
      return
  end

  path_length = 0.0;
  for idx=start_index:height(path)-1
      path_length = path_length + euclidean_distance(path(idx, :), path(idx+1, :));
  end
  l =  path_length;
  end




function d = euclidean_distance(pos1, pos2)

  dx = pos1(1) - pos2(1);
  dy = pos1(2) - pos2(2);

  d = sqrt(dx * dx +  dy * dy);
end