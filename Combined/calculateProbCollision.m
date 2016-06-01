function probCollision = calculateProbCollision(USERS, Parameters)

arrivals = [USERS.reportArrivals]>0; 
collisions= [USERS.rachCollisions]>0;
probCollision = sum(collisions)/sum(arrivals);

end